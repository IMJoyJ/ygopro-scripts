--光子竜の聖騎士
-- 效果：
-- 「光子龙降临」降临。把这张卡解放才能发动。从手卡·卡组把1只「银河眼光子龙」特殊召唤。此外，这张卡战斗破坏对方怪兽送去墓地时，从卡组抽1张卡。
function c85346853.initial_effect(c)
	c:EnableReviveLimit()
	-- 把这张卡解放才能发动。从手卡·卡组把1只「银河眼光子龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85346853,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c85346853.spcost)
	e1:SetTarget(c85346853.sptg)
	e1:SetOperation(c85346853.spop)
	c:RegisterEffect(e1)
	-- 此外，这张卡战斗破坏对方怪兽送去墓地时，从卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85346853,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c85346853.drcon)
	e2:SetTarget(c85346853.drtg)
	e2:SetOperation(c85346853.drop)
	c:RegisterEffect(e2)
end
-- 起动效果的代价：检查自身是否可以解放，并解放自身
function c85346853.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：在手卡·卡组中检索卡名为「银河眼光子龙」且可以特殊召唤的怪兽
function c85346853.spfilter(c,e,tp)
	return c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 起动效果的发动准备：检查怪兽区域空位数，以及手卡·卡组是否存在可特殊召唤的「银河眼光子龙」，并设置特殊召唤的操作信息
function c85346853.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域的空位数（因为自身作为代价解放，空位数需大于等于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组是否存在至少1只满足特殊召唤条件的「银河眼光子龙」
		and Duel.IsExistingMatchingCard(c85346853.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 起动效果的效果处理：从手卡·卡组选择1只「银河眼光子龙」以表侧表示特殊召唤
function c85346853.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有可用空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的「银河眼光子龙」
	local g=Duel.SelectMatchingCard(tp,c85346853.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 诱发效果的发动条件：自身在场且与战斗相关，且被战斗破坏的对方怪兽被送去墓地
function c85346853.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsFaceup()
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER) and bc:IsReason(REASON_BATTLE)
end
-- 诱发效果的发动准备：设置抽卡的目标玩家和张数，并设置抽卡的操作信息
function c85346853.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置抽卡的操作信息，表示让目标玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 诱发效果的效果处理：获取目标玩家和抽卡张数，执行抽卡
function c85346853.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
