--シューティング・セイヴァー・スター・ドラゴン
-- 效果：
-- 「救世龙」＋包含龙族同调怪兽的除调整以外的怪兽1只以上
-- 这张卡用同调召唤才能从额外卡组特殊召唤。
-- ①：1回合1次，可以发动。选对方场上1只效果怪兽，那个效果无效。
-- ②：这张卡在通常攻击外加上可以作出最多有自己墓地的「星尘龙」以及有那个卡名记述的同调怪兽数量的攻击。
-- ③：1回合1次，对方把效果发动时才能发动。这张卡直到结束阶段除外，那个发动无效并除外。
local s,id,o=GetID()
-- 初始化卡片效果，设置同调召唤所需素材和条件，启用复活限制
function c40939228.initial_effect(c)
	-- 为卡片添加允许作为同调素材的卡牌代码21159309（救世龙）
	aux.AddMaterialCodeList(c,21159309)
	-- 为卡片添加效果文本中记载的卡牌代码44508094（星尘龙）
	aux.AddCodeList(c,44508094)
	-- 设置混合同调召唤程序，要求包含调整和非调整的龙族同调怪兽作为素材
	aux.AddSynchroMixProcedure(c,aux.Tuner(Card.IsCode,21159309),nil,nil,aux.NonTuner(nil),1,99,c40939228.syncheck)
	c:EnableReviveLimit()
	-- 设置该卡只能通过同调召唤从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	-- 设置该卡只能通过同调召唤从额外卡组特殊召唤
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- 设置效果①：1回合1次，可以发动。选对方场上1只效果怪兽，那个效果无效
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40939228,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c40939228.distg)
	e2:SetOperation(c40939228.disop)
	c:RegisterEffect(e2)
	-- 设置效果②：这张卡在通常攻击外加上可以作出最多有自己墓地的「星尘龙」以及有那个卡名记述的同调怪兽数量的攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c40939228.atkval)
	c:RegisterEffect(e3)
	-- 设置效果③：1回合1次，对方把效果发动时才能发动。这张卡直到结束阶段除外，那个发动无效并除外
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(40939228,1))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c40939228.negcon)
	e4:SetTarget(c40939228.negtg)
	e4:SetOperation(c40939228.negop)
	c:RegisterEffect(e4)
end
c40939228.material_type=TYPE_SYNCHRO
-- 过滤函数，用于判断是否为龙族同调怪兽且不是调整
function c40939228.cfilter(c,syncard)
	return c:IsRace(RACE_DRAGON) and c:IsSynchroType(TYPE_SYNCHRO) and c:IsNotTuner(syncard)
end
-- 同调检查函数，用于判断所选素材中是否存在满足条件的龙族同调怪兽
function c40939228.syncheck(g,syncard)
	return g:IsExists(c40939228.cfilter,1,nil,syncard)
end
-- 效果①的目标选择函数，检查对方场上是否存在可无效的效果怪兽
function c40939228.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可无效的效果怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置效果①的处理信息，指定将要无效的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,LOCATION_MZONE)
end
-- 效果①的处理函数，选择并无效对方场上的一只效果怪兽
function c40939228.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要无效的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上的一只效果怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 显示所选怪兽被选为对象的动画效果
		Duel.HintSelection(g)
		-- 使与该怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 为被选中的怪兽添加效果无效化效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 为被选中的怪兽添加效果无效化效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 攻击次数计算函数，用于判断墓地中星尘龙或其同调怪兽数量
function c40939228.atkfilter(c)
	-- 判断是否为星尘龙或其同调怪兽
	return c:IsCode(44508094) or aux.IsCodeListed(c,44508094) and c:IsType(TYPE_SYNCHRO)
end
-- 效果②的攻击次数计算函数，返回墓地中符合条件的怪兽数量
function c40939228.atkval(e,c)
	-- 返回墓地中符合条件的怪兽数量
	return Duel.GetMatchingGroupCount(c40939228.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
end
-- 效果③的发动条件函数，检查是否满足发动条件
function c40939228.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足发动条件
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- 效果③的目标选择函数，检查是否满足发动条件并设置处理信息
function c40939228.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足发动条件
	if chk==0 then return c:IsAbleToRemove() and aux.nbcon(tp,re) end
	-- 设置效果③的处理信息，指定将要无效的连锁
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置效果③的处理信息，指定将要除外的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		local g=eg:Clone()+c
		-- 设置效果③的处理信息，指定将要除外的卡片组
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	end
	if re:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(e:GetCategory()|CATEGORY_GRAVE_ACTION)
	else
		e:SetCategory(e:GetCategory()&~CATEGORY_GRAVE_ACTION)
	end
end
-- 效果③的处理函数，将自身除外并无效对方发动的效果
function c40939228.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 检查是否满足除外条件
	if c:IsRelateToEffect(e) and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		if c:GetOriginalCode()==id then
			c:RegisterFlagEffect(40939228,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			-- 注册一个在结束阶段将自身返回场上的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabel(fid)
			e1:SetLabelObject(c)
			e1:SetCountLimit(1)
			e1:SetCondition(c40939228.retcon)
			e1:SetOperation(c40939228.retop)
			-- 注册效果
			Duel.RegisterEffect(e1,tp)
		end
		-- 检查是否满足无效并除外的条件
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 将对方发动的效果相关卡牌除外
			Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 检查是否满足返回场上的条件
function c40939228.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(40939228)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 将自身返回场上
function c40939228.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
