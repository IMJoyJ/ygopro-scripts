--ゴルゴニック・アンブラル
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌特召并检索「哥尔贡」怪兽效果、②额外特召限制效果、③作为No.超量素材时可当做2只素材效果
function s.initial_effect(c)
	-- ①：自己场上没有「哥尔贡」怪兽以外的怪兽存在的场合才能发动。这张卡从手牌特殊召唤，从卡组把1只岩石族以外的「哥尔贡」怪兽加入手牌。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己从额外卡组只能特殊召唤「No.」超量怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	-- ③：把场上的这张卡作为「No.」怪兽的超量召唤的素材的场合，这张卡可以当作2只分量的素材使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.sxyzfilter)
	e3:SetValue(id)
	e3:SetCountLimit(1,id+o)
	c:RegisterEffect(e3)
end
-- 场上怪兽检查过滤：里侧表示怪兽或非「哥尔贡」怪兽
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x87)
end
-- ①效果发动条件检查：自己场上没有里侧怪兽及非「哥尔贡」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己场上不存在不符合条件的怪兽
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 检索目标过滤条件：卡组中岩石族以外的可加入手牌的「哥尔贡」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x87) and not c:IsRace(RACE_ROCK) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand()
end
-- ①效果发动准备与条件检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：自己怪兽区域有空位且自身可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且卡组存在符合条件的岩石族以外的「哥尔贡」怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：特殊召唤自身，成功后从卡组检索1只岩石族以外的「哥尔贡」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡关联且成功将自身表侧表示特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 特召成功后检查卡组是否存在可检索怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只满足条件的「哥尔贡」怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果限制条件：从额外卡组不能特殊召唤「No.」超量怪兽以外的怪兽
function s.splimit(e,c)
	return not (c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
-- ③效果适用目标条件：超量召唤的目标怪兽为「No.」怪兽
function s.sxyzfilter(e,c)
	return c:IsSetCard(0x48)
end
