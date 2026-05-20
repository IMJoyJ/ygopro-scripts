--星遺物に差す影
-- 效果：
-- ①：场上的「机怪虫」怪兽的攻击力·守备力上升300。
-- ②：1回合1次，自己主要阶段才能发动。从手卡把1只2星以下的昆虫族怪兽表侧守备表示或者里侧守备表示特殊召唤。
-- ③：自己的反转怪兽被和对方怪兽的战斗破坏时才能发动。那只对方怪兽送去墓地。
function c67831115.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「机怪虫」怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果影响的目标为字段名含有「机怪虫」（0x104）的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x104))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己主要阶段才能发动。从手卡把1只2星以下的昆虫族怪兽表侧守备表示或者里侧守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(67831115,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c67831115.sptg)
	e4:SetOperation(c67831115.spop)
	c:RegisterEffect(e4)
	-- ③：自己的反转怪兽被和对方怪兽的战斗破坏时才能发动。那只对方怪兽送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(67831115,1))
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYED)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(c67831115.tgcon)
	e5:SetTarget(c67831115.tgtg)
	e5:SetOperation(c67831115.tgop)
	c:RegisterEffect(e5)
end
-- 过滤条件：手卡中等级2以下、可以守备表示特殊召唤的昆虫族怪兽
function c67831115.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- 效果②的发动准备与合法性检测（检查怪兽区域空位及手卡中是否存在符合条件的怪兽）
function c67831115.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c67831115.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的实际处理（从手卡选择1只符合条件的怪兽特殊召唤，若里侧特殊召唤则向对方确认）
function c67831115.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，以及此场地魔法卡是否仍在场上，若不满足则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c67831115.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 将选中的怪兽以守备表示（表侧或里侧）特殊召唤，若特殊召唤成功且为里侧守备表示
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
			-- 向对方玩家确认该里侧特殊召唤的怪兽
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
-- 过滤条件：因战斗破坏送去墓地的、原本控制者为自己的反转怪兽，且击破它的对方怪兽仍存在于战斗中
function c67831115.cfilter(c,tp)
	local rc=c:GetReasonCard()
	return c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp) and c:IsType(TYPE_FLIP)
		and rc and rc:IsControler(1-tp) and rc:IsRelateToBattle()
end
-- 效果③的发动条件检测（获取被战斗破坏的反转怪兽，并将击破它的对方怪兽作为标签对象保存）
function c67831115.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local dc=eg:Filter(c67831115.cfilter,nil,tp):GetFirst()
	if dc then
		e:SetLabelObject(dc:GetReasonCard())
		return true
	else return false end
end
-- 效果③的发动准备（设置将对方怪兽送去墓地的操作信息）
function c67831115.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理中的操作信息：将保存的对方怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetLabelObject(),1,0,0)
end
-- 效果③的实际处理（将进行战斗的对方怪兽送去墓地）
function c67831115.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsRelateToBattle() then
		-- 用效果将该对方怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
