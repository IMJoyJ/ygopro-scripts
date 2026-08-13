--シューティング・セイヴァー・スター・ドラゴン
-- 效果：
-- 「救世龙」＋包含龙族同调怪兽的除调整以外的怪兽1只以上
-- 这张卡用同调召唤才能从额外卡组特殊召唤。
-- ①：1回合1次，可以发动。选对方场上1只效果怪兽，那个效果无效。
-- ②：这张卡在通常攻击外加上可以作出最多有自己墓地的「星尘龙」以及有那个卡名记述的同调怪兽数量的攻击。
-- ③：1回合1次，对方把效果发动时才能发动。这张卡直到结束阶段除外，那个发动无效并除外。
local s,id,o=GetID()
-- 初始化卡片：注册救世龙素材、星尘龙卡名记录、同调召唤手续与苏生限制，并注册①无效怪兽效果、②追加攻击、③无效并除外三个效果。
function c40939228.initial_effect(c)
	-- 将「救世龙」（21159309）登记为这张卡的同调素材卡名，使同调召唤手续能够识别该素材。
	aux.AddMaterialCodeList(c,21159309)
	-- 将「星尘龙」（44508094）登记为这张卡效果文本中记载的关联卡名，供②效果统计相关怪兽数量时识别。
	aux.AddCodeList(c,44508094)
	-- 设定混合同调召唤手续：以「救世龙」作为调整素材，加上1只以上任意调整以外怪兽，且素材组中必须包含至少1只龙族同调怪兽（由 syncheck 检查）。
	aux.AddSynchroMixProcedure(c,aux.Tuner(Card.IsCode,21159309),nil,nil,aux.NonTuner(nil),1,99,c40939228.syncheck)
	c:EnableReviveLimit()
	-- 这张卡用同调召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	-- 设置该特殊召唤限制效果的判定函数：只允许通过同调召唤方式特殊召唤，其他方式均不可特殊召唤。
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以发动。选对方场上1只效果怪兽，那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40939228,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c40939228.distg)
	e2:SetOperation(c40939228.disop)
	c:RegisterEffect(e2)
	-- ②：这张卡在通常攻击外加上可以作出最多有自己墓地的「星尘龙」以及有那个卡名记述的同调怪兽数量的攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c40939228.atkval)
	c:RegisterEffect(e3)
	-- ③：1回合1次，对方把效果发动时才能发动。这张卡直到结束阶段除外，那个发动无效并除外。
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
-- 素材过滤函数：判断素材怪兽是否为非调整的龙族同调怪兽，用于同调素材组的合法性检查。
function c40939228.cfilter(c,syncard)
	return c:IsRace(RACE_DRAGON) and c:IsSynchroType(TYPE_SYNCHRO) and c:IsNotTuner(syncard)
end
-- 同调素材检查函数：确认所选素材组中存在至少1只满足 cfilter 的龙族同调怪兽。
function c40939228.syncheck(g,syncard)
	return g:IsExists(c40939228.cfilter,1,nil,syncard)
end
-- ①效果发动前的目标检测与操作信息登记：检查对方场上存在可无效的表侧效果怪兽，并登记无效效果类别。
function c40939228.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检测：对方场上是否存在至少1只表侧表示且可被无效的效果怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息：该效果属于无效化效果，不取对象地预计处理对方场上1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,LOCATION_MZONE)
end
-- ①效果处理：从对方场上选择1只表侧效果怪兽，使其效果无效化，并使与该怪兽相关的连锁无效。
function c40939228.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示信息，要求玩家选择要无效的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从对方主要怪兽区选择1只符合条件的可被无效的表侧效果怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 为被选中的怪兽显示对象选择动画，并将其登记为效果的对象。
		Duel.HintSelection(g)
		-- 使与所选怪兽相关的连锁也无效化，重置条件为回合结束。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那个效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那个效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 额外攻击次数的计数过滤：匹配卡名是「星尘龙」的卡，或效果文本中记载了「星尘龙」的同调怪兽。
function c40939228.atkfilter(c)
	-- 匹配条件：c 是「星尘龙」，或 c 是同调怪兽且其效果文本记载了「星尘龙」。
	return c:IsCode(44508094) or aux.IsCodeListed(c,44508094) and c:IsType(TYPE_SYNCHRO)
end
-- 额外攻击次数的取值函数：统计自己墓地中满足 atkfilter 的卡片数量。
function c40939228.atkval(e,c)
	-- 返回自己墓地中满足 atkfilter 的卡片数量，作为追加攻击次数。
	return Duel.GetMatchingGroupCount(c40939228.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
end
-- ③效果发动条件：这张卡未被战斗破坏、对方发动了效果、且该连锁能够被无效。
function c40939228.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定：这张卡不处于战斗破坏状态，当前连锁可被无效，且效果发动方是对方。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- ③效果发动可行性判定与操作信息登记：确认自身可除外且对方连锁可无效，设置无效/除外操作信息；若对方效果在墓地发动则附加墓地效果类别。
function c40939228.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查这张卡是否能被除外，以及对方效果是否满足可被无效并除外的条件。
	if chk==0 then return c:IsAbleToRemove() and aux.nbcon(tp,re) end
	-- 设置操作信息：将使对方发动的连锁无效，对象为连锁中的效果卡片。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：将把这张卡自身除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		local g=eg:Clone()+c
		-- 若对方效果卡片仍与该连锁关联，则将其与这张卡合并作为被除外的对象登记。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	end
	if re:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(e:GetCategory()|CATEGORY_GRAVE_ACTION)
	else
		e:SetCategory(e:GetCategory()&~CATEGORY_GRAVE_ACTION)
	end
end
-- ③效果处理：先将这张卡以暂时除外方式除外并登记结束阶段归还效果；再无效对方连锁，成功后除外对方效果卡片。
function c40939228.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 确认这张卡仍与发动效果关联后，将其以效果·暂时除外方式除外；若除外成功则继续处理。
	if c:IsRelateToEffect(e) and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		if c:GetOriginalCode()==id then
			c:RegisterFlagEffect(40939228,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			-- 这张卡直到结束阶段除外，那个发动无效并除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabel(fid)
			e1:SetLabelObject(c)
			e1:SetCountLimit(1)
			e1:SetCondition(c40939228.retcon)
			e1:SetOperation(c40939228.retop)
			-- 注册一个持续效果，在结束阶段将暂时除外的这张卡返回场上。
			Duel.RegisterEffect(e1,tp)
		end
		-- 若对方连锁发动被成功无效，且对方效果卡片仍与该连锁关联，则继续将该效果卡片除外。
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 将对方发动效果的那张卡以表侧表示除外。
			Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 结束阶段归还效果的发动条件：检查要归还的卡是否仍带有本次除外登记的标记；标记一致才允许归还，否则重置该效果。
function c40939228.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(40939228)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段归还效果的处理：把暂时除外的这张卡返回场上。
function c40939228.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将之前暂时除外的这张卡返回到场上。
	Duel.ReturnToField(e:GetLabelObject())
end
