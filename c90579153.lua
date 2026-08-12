--D-HERO ディストピアガイ
-- 效果：
-- 「命运英雄」怪兽×2
-- 「命运英雄 敌托邦人」的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以自己墓地1只4星以下的「命运英雄」怪兽为对象才能发动。给与对方那只怪兽的攻击力数值的伤害。
-- ②：这张卡的攻击力和原本攻击力不同的场合，以场上1张卡为对象才能发动。那张卡破坏，这张卡的攻击力变成原本数值。这个效果在对方回合也能发动。
function c90579153.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤手续，需要2只「命运英雄」怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc008),2,true)
	-- ①：这张卡特殊召唤成功的场合，以自己墓地1只4星以下的「命运英雄」怪兽为对象才能发动。给与对方那只怪兽的攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90579153,0))  --"给与对方伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,90579153)
	e1:SetTarget(c90579153.damtg)
	e1:SetOperation(c90579153.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力和原本攻击力不同的场合，以场上1张卡为对象才能发动。那张卡破坏，这张卡的攻击力变成原本数值。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90579153,1))  --"场上1张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,90579154)
	e2:SetCondition(c90579153.descon)
	e2:SetTarget(c90579153.destg)
	e2:SetOperation(c90579153.desop)
	c:RegisterEffect(e2)
end
c90579153.material_setcode=0xc008
-- 过滤自己墓地中攻击力大于0且等级在4星以下的「命运英雄」怪兽。
function c90579153.filter(c)
	return c:IsSetCard(0xc008) and c:IsLevelBelow(4) and c:GetAttack()>0
end
-- 效果①（伤害效果）的发动准备与目标选择。
function c90579153.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90579153.filter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的4星以下「命运英雄」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c90579153.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己墓地1只满足条件的4星以下「命运英雄」怪兽作为对象。
	local g=Duel.SelectTarget(tp,c90579153.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，准备给与对方等同于目标怪兽攻击力数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
-- 效果①（伤害效果）的效果处理。
function c90579153.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的墓地怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 给与对方该怪兽攻击力数值的伤害。
		Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡的攻击力和原本攻击力不同。
function c90579153.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsAttack(c:GetBaseAttack())
end
-- 效果②（破坏效果）的发动准备与目标选择。
function c90579153.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少1张卡可以作为破坏对象。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，准备破坏选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②（破坏并重置攻击力）的效果处理。
function c90579153.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②选择的场上卡片对象。
	local tc=Duel.GetFirstTarget()
	-- 若目标卡片成功被效果破坏，且自身仍在场上表侧表示存在，则继续处理后续效果。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=c:GetBaseAttack()
		-- 这张卡的攻击力变成原本数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
