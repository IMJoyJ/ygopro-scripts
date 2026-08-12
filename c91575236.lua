--イモータル・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从卡组把1只不死族怪兽送去墓地，这张卡的等级变成与那只怪兽和这张卡的原本等级差的数值相同。
-- ②：这张卡在墓地存在的状态，自己的不死族怪兽被战斗破坏时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化函数：注册同调召唤手续，以及该卡名的①②效果（①主要阶段从卡组送墓不死族并改变等级，②墓地存在时己方不死族被战破时特召并离场除外）
function c91575236.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。从卡组把1只不死族怪兽送去墓地，这张卡的等级变成与那只怪兽和这张卡的原本等级差的数值相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,91575236)
	e1:SetTarget(c91575236.tgtg)
	e1:SetOperation(c91575236.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的不死族怪兽被战斗破坏时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,91575236+o)
	e2:SetCondition(c91575236.spcon)
	e2:SetTarget(c91575236.sptg)
	e2:SetOperation(c91575236.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中满足条件的不死族怪兽：其原本等级与这张卡原本等级不同，且原本等级差不等于这张卡当前的等级
function c91575236.tgfilter(c,lv,olv)
	local clv=c:GetOriginalLevel()
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave() and clv~=olv and math.abs(clv-olv)~=lv
end
-- 效果①的发动准备与合法性检测：检查卡组中是否存在可送墓且能改变等级的不死族怪兽，并设置送去墓地的操作信息
function c91575236.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return c:IsLevelAbove(0)
			-- 检查卡组中是否存在至少1只满足过滤条件的不死族怪兽
			and Duel.IsExistingMatchingCard(c91575236.tgfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),c:GetOriginalLevel())
	end
	-- 设置当前连锁的操作信息为：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1只不死族怪兽送去墓地，若成功，则将这张卡的等级变为两者的原本等级差
function c91575236.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足过滤条件的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,c91575236.tgfilter,tp,LOCATION_DECK,0,1,1,nil,c:GetLevel(),c:GetOriginalLevel())
	local tc=g:GetFirst()
	-- 若成功将选择的怪兽因效果送去墓地且该卡确实存在于墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 这张卡的等级变成与那只怪兽和这张卡的原本等级差的数值相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(math.abs(c:GetOriginalLevel()-tc:GetOriginalLevel()))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤在场上原本是自己控制的不死族怪兽
function c91575236.cfilter(c,tp)
	return c:GetPreviousRaceOnField()&RACE_ZOMBIE~=0 and c:IsPreviousControler(tp)
end
-- 效果②的发动条件：自己场上的不死族怪兽被战斗破坏，且被破坏的怪兽不包含墓地中的这张卡自身
function c91575236.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c91575236.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果②的发动准备与合法性检测：检查自己场上是否有空位以及自身是否可以特殊召唤
function c91575236.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将自身特殊召唤，并添加离场时除外的限制
function c91575236.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自身仍存在于墓地，则将其以表侧表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
