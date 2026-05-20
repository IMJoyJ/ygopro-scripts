--セイヴァー・デモン・ドラゴン
-- 效果：
-- 「救世龙」＋「红莲魔龙」＋调整以外的怪兽1只
-- 这张卡不会被卡的效果破坏。这张卡攻击的场合，伤害计算后把场上守备表示存在的怪兽全部破坏。1回合1次，可以直到结束阶段时把对方1只表侧表示怪兽的效果无效，这张卡的攻击力上升那只怪兽的攻击力数值。结束阶段时这张卡回到额外卡组，把自己墓地存在的1只「红莲魔龙」特殊召唤。
function c67030233.initial_effect(c)
	-- 将「救世龙」和「红莲魔龙」的卡片密码注册为此卡的特定素材列表，以便其他卡片效果进行关联检索。
	aux.AddMaterialCodeList(c,21159309,70902743)
	-- 为此卡添加同调召唤手续：需要「救世龙」作为素材1、「红莲魔龙」作为素材2，以及1只非调整怪兽。
	aux.AddSynchroMixProcedure(c,c67030233.mfilter1,c67030233.mfilter2,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- 这张卡攻击的场合，伤害计算后把场上守备表示存在的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67030233,0))  --"守备怪兽全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c67030233.descon)
	e2:SetTarget(c67030233.destg)
	e2:SetOperation(c67030233.desop)
	c:RegisterEffect(e2)
	-- 1回合1次，可以直到结束阶段时把对方1只表侧表示怪兽的效果无效，这张卡的攻击力上升那只怪兽的攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67030233,1))  --"效果无效化"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c67030233.distg)
	e3:SetOperation(c67030233.disop)
	c:RegisterEffect(e3)
	-- 结束阶段时这张卡回到额外卡组，把自己墓地存在的1只「红莲魔龙」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(67030233,2))  --"返回额外卡组"
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e4:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetTarget(c67030233.sptg)
	e4:SetOperation(c67030233.spop)
	c:RegisterEffect(e4)
	-- 这张卡不会被卡的效果破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
c67030233.material_type=TYPE_SYNCHRO
-- 同调素材过滤函数：判定卡片是否为「救世龙」。
function c67030233.mfilter1(c)
	return c:IsCode(21159309)
end
-- 同调素材过滤函数：判定卡片是否为「红莲魔龙」，且在同调召唤中作为调整使用。
function c67030233.mfilter2(c,syncard,c1)
	return c:IsCode(70902743) and (c:IsTuner(syncard) or c1:IsTuner(syncard))
end
-- 守备表示怪兽破坏效果的发动条件判定函数。
function c67030233.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定此卡是否为当前进行攻击的怪兽。
	return e:GetHandler()==Duel.GetAttacker()
end
-- 破坏效果的过滤函数：判定怪兽是否处于守备表示。
function c67030233.desfilter(c)
	return c:IsDefensePos()
end
-- 守备表示怪兽破坏效果的发动准备与目标确认函数。
function c67030233.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上双方所有的守备表示怪兽。
	local g=Duel.GetMatchingGroup(c67030233.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁处理的操作信息：破坏场上所有的守备表示怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 守备表示怪兽破坏效果的执行函数。
function c67030233.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取场上双方所有的守备表示怪兽。
	local g=Duel.GetMatchingGroup(c67030233.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 因卡片效果破坏获取到的所有守备表示怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果无效与攻击力上升效果的发动准备与目标选择函数。
function c67030233.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判定指向的对象是否为对方场上表侧表示且未被无效的效果怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 判定对方场上是否存在至少1只可以被无效效果的表侧表示效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，要求选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只表侧表示的效果怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理的操作信息：使选中的1只怪兽效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果无效与攻击力上升效果的执行函数。
function c67030233.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 直到结束阶段时把对方1只表侧表示怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 直到结束阶段时把对方1只表侧表示怪兽的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 这张卡的攻击力上升那只怪兽的攻击力数值。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetValue(atk)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
	end
end
-- 特殊召唤的过滤函数：判定怪兽是否为「红莲魔龙」且可以被特殊召唤。
function c67030233.spfilter(c,e,tp)
	return c:IsCode(70902743) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 回额外卡组并特殊召唤效果的发动准备与目标选择函数。
function c67030233.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67030233.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 给玩家发送提示信息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只「红莲魔龙」作为特殊召唤的对象。
	local g=Duel.SelectTarget(tp,c67030233.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息：将自身送回额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
	-- 设置连锁处理的操作信息：将选中的怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 回额外卡组并特殊召唤效果的执行函数。
function c67030233.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为特殊召唤对象的怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 判定此卡是否仍存在于场上且为额外卡组怪兽，并将其送回额外卡组。
	if c:IsRelateToEffect(e) and c:IsExtraDeckMonster() and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_EXTRA) and tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
