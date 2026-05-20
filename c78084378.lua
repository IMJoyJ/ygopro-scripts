--ダイプレクサ・キマイラ
-- 效果：
-- 电子界族怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，把自己场上1只电子界族怪兽解放才能发动。这个回合的战斗阶段中双方不能把魔法·陷阱卡的效果发动。
-- ②：融合召唤的这张卡被送去墓地的场合，以这张卡以外的自己墓地1只电子界族怪兽和1张「电脑网融合」为对象才能发动。那些卡加入手卡。
function c78084378.initial_effect(c)
	-- 设置融合召唤素材：电子界族怪兽2只
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE),2,true)
	c:EnableReviveLimit()
	-- ①：1回合1次，把自己场上1只电子界族怪兽解放才能发动。这个回合的战斗阶段中双方不能把魔法·陷阱卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78084378,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c78084378.con)
	e1:SetCost(c78084378.cost)
	e1:SetOperation(c78084378.operation)
	c:RegisterEffect(e1)
	-- ②：融合召唤的这张卡被送去墓地的场合，以这张卡以外的自己墓地1只电子界族怪兽和1张「电脑网融合」为对象才能发动。那些卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78084378,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,78084378)
	e2:SetCondition(c78084378.thcon)
	e2:SetTarget(c78084378.thtg)
	e2:SetOperation(c78084378.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c78084378.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 效果①的发动代价处理函数
function c78084378.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否存在可解放的电子界族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_CYBERSE) end
	-- 选择自己场上1只电子界族怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_CYBERSE)
	-- 解放选择的怪兽
	Duel.Release(g,REASON_COST)
end
-- 效果①的效果处理函数
function c78084378.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的战斗阶段中双方不能把魔法·陷阱卡的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetCondition(c78084378.accon)
	e1:SetValue(c78084378.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的适用条件：当前处于战斗阶段
function c78084378.accon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 限制发动的卡片类型：魔法·陷阱卡的效果
function c78084378.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果②的发动条件：融合召唤的这张卡从怪兽区域送去墓地
function c78084378.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤自己墓地中可以加入手牌的电子界族怪兽
function c78084378.filter1(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
end
-- 过滤自己墓地中可以加入手牌的「电脑网融合」
function c78084378.filter2(c)
	return c:IsCode(65801012) and c:IsAbleToHand()
end
-- 效果②的发动准备（选择对象与声明操作）
function c78084378.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动时，检查自己墓地是否存在除这张卡以外的电子界族怪兽
	if chk==0 then return Duel.IsExistingTarget(c78084378.filter1,tp,LOCATION_GRAVE,0,1,e:GetHandler())
		-- 并且检查自己墓地是否存在「电脑网融合」
		and Duel.IsExistingTarget(c78084378.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只除这张卡以外的电子界族怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c78084378.filter1,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张「电脑网融合」作为效果对象
	local g2=Duel.SelectTarget(tp,c78084378.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息：将这2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果②的效果处理函数
function c78084378.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍存在于墓地且符合对象条件的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
