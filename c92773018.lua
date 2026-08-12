--サイバネティック・ヒドゥン・テクノロジー
-- 效果：
-- 每次对方怪兽进行攻击宣言，把自己场上1只「电子龙」或者作为融合素材有「电子龙」记述的融合怪兽送去墓地才能发动。选择那1只攻击怪兽破坏。
function c92773018.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次对方怪兽进行攻击宣言，把自己场上1只「电子龙」或者作为融合素材有「电子龙」记述的融合怪兽送去墓地才能发动。选择那1只攻击怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92773018,0))  --"攻击怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c92773018.condition)
	e2:SetCost(c92773018.cost)
	e2:SetTarget(c92773018.target)
	e2:SetOperation(c92773018.activate)
	c:RegisterEffect(e2)
end
-- 效果发动条件函数（对方怪兽攻击宣言时）
function c92773018.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 验证当前回合玩家不是自己（即对方回合的攻击宣言）
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤作为发动代价送去墓地的怪兽的条件函数
function c92773018.cfilter(c)
	-- 检查卡片是否为表侧表示的「电子龙」或作为融合素材有「电子龙」记述的融合怪兽
	return c:IsFaceup() and (c:IsCode(70095154) or c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,70095154))
		and c:IsAbleToGraveAsCost()
end
-- 效果发动代价函数
function c92773018.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动代价处理的第一步，检查自身场上是否存在至少1只满足条件的怪兽可以送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c92773018.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息，要求选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c92773018.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标选择函数
function c92773018.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将该攻击怪兽设为效果的对象
	Duel.SetTargetCard(tg)
	-- 设置效果处理信息为破坏该攻击怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 效果处理（破坏）函数
function c92773018.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的攻击怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		-- 破坏该攻击怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
