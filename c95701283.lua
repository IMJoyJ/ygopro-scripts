--光神機－轟龍
-- 效果：
-- 这张卡可以用1只祭品作召唤。这个方法召唤的场合，这张卡在结束阶段时送去墓地。此外，这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c95701283.initial_effect(c)
	-- 这张卡可以用1只祭品作召唤。这个方法召唤的场合，这张卡在结束阶段时送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95701283,0))  --"用1只祭品作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c95701283.otcon)
	e1:SetOperation(c95701283.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 此外，这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 定义用1只祭品作召唤的条件过滤函数
function c95701283.otcon(e,c,minc)
	if c==nil then return true end
	-- 判断自身等级是否在7星以上、要求的最小祭品数是否小于等于1，且场上是否存在1个可解放的怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1)
end
-- 定义用1只祭品作召唤的具体操作函数，并注册结束阶段送去墓地的效果
function c95701283.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择1个怪兽作为上级召唤的祭品
	local g=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(g)
	-- 解放选中的怪兽作为召唤素材
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
	-- 这个方法召唤的场合，这张卡在结束阶段时送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95701283,1))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(c95701283.tgtg)
	e1:SetOperation(c95701283.tgop)
	e1:SetReset(RESET_EVENT+0xc6e0000)
	c:RegisterEffect(e1)
end
-- 定义结束阶段送去墓地效果的靶向/发动检测函数
function c95701283.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将自身送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 定义结束阶段送去墓地效果的执行函数
function c95701283.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 因效果将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
