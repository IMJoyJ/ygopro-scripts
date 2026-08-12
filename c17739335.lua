--呪眼の王 ザラキエル
-- 效果：
-- 「咒眼」怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：攻击力2600以上的怪兽为素材作连接召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡有「太阴之咒眼」装备的场合，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果在对方回合也能发动。
-- ③：这张卡的②的效果发动的场合，下次的准备阶段发动。选这张卡所连接区1只效果怪兽，那个效果无效。
function c17739335.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2只属于「咒眼」的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x129),2)
	c:EnableReviveLimit()
	-- ①：攻击力2600以上的怪兽为素材作连接召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c17739335.regcon)
	e1:SetOperation(c17739335.regop)
	c:RegisterEffect(e1)
	-- ②：这张卡有「太阴之咒眼」装备的场合，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c17739335.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ③：这张卡的②的效果发动的场合，下次的准备阶段发动。选这张卡所连接区1只效果怪兽，那个效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	e3:SetCondition(c17739335.macon)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(17739335,0))  --"卡片破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,17739335)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(c17739335.descon)
	e4:SetTarget(c17739335.destg)
	e4:SetOperation(c17739335.desop)
	c:RegisterEffect(e4)
	-- 攻击力2600以上的怪兽作为连接素材
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(17739335,1))  --"效果无效"
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c17739335.discon)
	e5:SetTarget(c17739335.distg)
	e5:SetOperation(c17739335.disop)
	c:RegisterEffect(e5)
end
-- 当此卡通过连接召唤成功特殊召唤时触发
function c17739335.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 记录此卡使用了攻击力2600以上的怪兽作为连接素材
function c17739335.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(17739336,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(17739335,2))  --"攻击力2600以上的怪兽作为连接素材"
end
-- 当此卡使用了攻击力2600以上的怪兽作为连接素材时，可进行额外攻击
function c17739335.macon(e)
	return e:GetHandler():GetFlagEffect(17739336)>0
end
-- 检查连接素材中是否存在攻击力2600以上的怪兽，若存在则设置标签为1
function c17739335.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttackAbove,1,nil,2600) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 当此卡装备有「太阴之咒眼」时，可发动破坏效果
function c17739335.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsCode,1,nil,44133040)
end
-- 选择对方场上的1张卡作为破坏对象
function c17739335.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判断是否能选择对方场上的1张卡作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为破坏对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 判断当前阶段是否为准备阶段
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 注册标记，用于记录此卡在准备阶段是否已发动过效果
		e:GetHandler():RegisterFlagEffect(17739335,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(17739335,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,1,0)
	end
end
-- 执行破坏操作，将目标卡破坏
function c17739335.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否满足发动效果的条件
function c17739335.discon(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(17739335)
	-- 判断此卡是否在当前回合已发动过效果
	return tid and tid~=Duel.GetTurnCount()
end
-- 筛选可被无效化的怪兽
function c17739335.disfilter(c,g)
	-- 判断目标怪兽是否为效果怪兽且在连接区中
	return aux.NegateEffectMonsterFilter(c) and g:IsContains(c)
end
-- 设置操作信息为无效对象
function c17739335.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local cg=e:GetHandler():GetLinkedGroup()
	-- 筛选连接区中的效果怪兽作为无效对象
	local g=Duel.GetMatchingGroup(c17739335.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
	-- 设置操作信息为无效对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 执行无效化操作，使目标怪兽效果无效
function c17739335.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetLinkedGroup()
	-- 筛选连接区中的效果怪兽作为无效对象
	local g=Duel.GetMatchingGroup(c17739335.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
	if g:GetCount()>0 then
		-- 提示玩家选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显示所选卡作为无效对象的动画
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		-- 使目标怪兽相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
