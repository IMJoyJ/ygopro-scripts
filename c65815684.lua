--ヴィシャス＝アストラウド
-- 效果：
-- 「维萨斯-斯塔弗罗斯特」＋攻击力1500/守备力2100的怪兽
-- 把自己的场上·墓地的上记卡除外的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只怪兽为对象才能发动。那只怪兽破坏，这张卡的攻击力上升那个原本攻击力和原本守备力之内较高方数值的一半。
-- ②：这张卡不会被战斗破坏。
local s,id,o=GetID()
-- 初始化函数，注册卡片的融合素材、接触融合召唤手续、特殊召唤限制、特殊召唤成功时的诱发效果以及不会被战斗破坏的永续效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合素材设定，指定「维萨斯-斯塔弗罗斯特」和1只满足特定条件的怪兽作为素材
	aux.AddFusionProcCodeFun(c,56099748,s.matfilter,1,true,true)
	-- 添加接触融合的特殊召唤手续，规定将自己场上或墓地的上述素材正面表示除外来特殊召唤
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己的场上·墓地的上记卡除外的场合才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只怪兽为对象才能发动。那只怪兽破坏，这张卡的攻击力上升那个原本攻击力和原本守备力之内较高方数值的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 融合素材过滤函数，筛选攻击力1500且守备力2100的怪兽
function s.matfilter(c)
	return c:IsAttack(1500) and c:IsDefense(2100) and c:IsType(TYPE_MONSTER)
end
-- 破坏并加攻效果的发动条件与对象选择函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=c end
	-- 在发动阶段进行可行性检查，判断场上是否存在除自身以外的可选怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 在客户端显示“选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上除自身以外的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置效果处理信息，声明该效果包含破坏1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏并加攻效果的效果处理函数，执行破坏怪兽并计算、增加自身攻击力的操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否存在、是否仍为该效果的对象，并将其破坏
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		local upval=tc:GetBaseAttack()
		if tc:GetBaseAttack()<tc:GetBaseDefense() then
			upval=tc:GetBaseDefense()
		end
		-- 这张卡的攻击力上升那个原本攻击力和原本守备力之内较高方数值的一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(upval/2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
