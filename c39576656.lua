--キラーチューン・クラックル
-- 效果：
-- 「杀手级调整曲·削波手」＋调整1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。把对方的额外卡组确认，那之内的1张直到结束阶段表侧除外。那之后，可以让这张卡的攻击力上升除外的怪兽的攻击力数值。
-- ②：同调召唤的这张卡被送去墓地的场合才能发动。这张卡特殊召唤。那之后，以下效果可以适用。
-- ●把对方的额外卡组确认，那之内的2张直到结束阶段表侧除外。
local s,id,o=GetID()
-- 定义卡片初始化入口：声明素材与同调召唤手续，并注册①效果（同调召唤成功后除外对方额外1张并可选加攻）、②效果（送墓自跳并可选再除外2张）及内置的同名效果一回合一次限制。
function s.initial_effect(c)
	-- 将卡号43904702（「杀手级调整曲·削波手」）加入这张卡的同调素材名列表。
	aux.AddMaterialCodeList(c,43904702)
	-- 设置混合同调召唤手续：需要1只「杀手级调整曲·削波手」作为素材，且素材中还包含1只以上调整，素材总数在1~99只之间。
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsCode,43904702),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。把对方的额外卡组确认，那之内的1张直到结束阶段表侧除外。那之后，可以让这张卡的攻击力上升除外的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"确认额外卡组并除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被送去墓地的场合才能发动。这张卡特殊召唤。那之后，以下效果可以适用。●把对方的额外卡组确认，那之内的2张直到结束阶段表侧除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(21142671)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：本卡是以同调召唤方式成功召唤的场合。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果的目标处理：检查对方额外卡组是否有可除外的卡，并设置除外1张的操作信息。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时确认对方额外卡组中存在至少1张可被除外的卡。
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)>0 end
	-- 设置连锁处理信息：本效果属于除外效果，预计除外对方额外卡组中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- ①效果处理：确认对方额外卡组并让玩家选择1张表侧除外；若除外的是怪兽，可再选择使本卡攻击力上升该怪兽攻击力数值，并在结束阶段将除外的卡返回持有者卡组。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得对方额外卡组的全部卡片。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g>0 then
		-- 将对方额外卡组的所有卡片展示给当前玩家确认。
		Duel.ConfirmCards(tp,g,true)
		-- 显示“请选择要除外的卡”的提示，引导玩家选择要除外的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
		local tc=sg:GetFirst()
		-- 若选中了卡片并成功将其以表侧表示、效果且临时除外方式除外，则进入后续处理。
		if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			local fid=c:GetFieldID()
			-- 取得实际被除外的卡片组，用于之后获取被除外怪兽的攻击力。
			local og=Duel.GetOperatedGroup()
			local oc=og:GetFirst()
			if oc then
				oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,4))  --"直到结束阶段除外"
				-- 把对方的额外卡组确认，那之内的1张直到结束阶段表侧除外。那之后，可以让这张卡的攻击力上升除外的怪兽的攻击力数值。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabel(fid)
				e1:SetLabelObject(oc)
				e1:SetCountLimit(1)
				e1:SetOperation(s.retop)
				-- 注册一个结束阶段触发的持续效果，用于将临时除外的卡送回持有者卡组。
				Duel.RegisterEffect(e1,tp)
				local atk=oc:GetAttack()
				-- 判断本卡仍与连锁相关且表侧表示，并且被除外的怪兽攻击力大于0时，询问控制者是否让本卡攻击力上升该数值。
				if c:IsRelateToChain() and c:IsFaceup() and atk>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否上升攻击力？"
					-- 那之后，可以让这张卡的攻击力上升除外的怪兽的攻击力数值。
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_UPDATE_ATTACK)
					e2:SetValue(atk)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
					c:RegisterEffect(e2)
				end
			end
		end
		-- 洗切对方的额外卡组。
		Duel.ShuffleExtra(1-tp)
	end
end
-- 结束阶段处理：若之前被临时除外的卡仍带有对应的标记，则将其返回持有者卡组。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local tc=e:GetLabelObject()
	if tc and tc:GetFlagEffectLabel(id)==fid then
		-- 将那张临时除外的卡以效果原因送回持有者卡组并洗切。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡被送去墓地前位于怪兽区域，且曾以同调召唤方式召唤过。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ②效果的目标处理：检查我方怪兽区域是否有空位，以及这张卡是否可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查我方怪兽区域是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息：本次效果将特殊召唤这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：将这张卡特殊召唤；成功后可选从对方额外卡组再确认并除外2张直到结束阶段，并在结束阶段返回。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与连锁相关、不受王家长眠之谷等影响，且特殊召唤成功，才继续后续可选的除外处理。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 取得对方额外卡组中所有可被除外的卡，作为后续选择的对象集合。
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
		-- 若可选卡数不少于2张，且控制者选择发动追加效果，则继续进行除外处理。
		if #g>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否除外额外卡组？"
			-- 中断当前效果处理，使特殊召唤成功后的后续除外部分另作处理，避免错过时点。
			Duel.BreakEffect()
			-- 再次确认并展示对方额外卡组的全部卡片。
			Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,0,LOCATION_EXTRA),true)
			-- 显示“请选择要除外的卡”的提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=g:FilterSelect(tp,Card.IsAbleToRemove,2,2,nil)
			if #sg==2 then
				local fid=c:GetFieldID()
				-- 若成功将选中的2张卡以表侧表示、效果且临时除外方式除外，则继续处理。
				if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
					-- 取得实际被除外的卡片组。
					local og=Duel.GetOperatedGroup()
					-- 遍历被除外的每张卡，为它们标记本次临时除外的对应信息。
					for oc in aux.Next(og) do
						oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,4))  --"直到结束阶段除外"
					end
					og:KeepAlive()
					-- ●把对方的额外卡组确认，那之内的2张直到结束阶段表侧除外。
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EVENT_PHASE+PHASE_END)
					e1:SetReset(RESET_PHASE+PHASE_END)
					e1:SetLabel(fid)
					e1:SetLabelObject(og)
					e1:SetCountLimit(1)
					e1:SetOperation(s.retop2)
					-- 注册一个结束阶段触发的持续效果，用于将这2张临时除外的卡送回持有者卡组。
					Duel.RegisterEffect(e1,tp)
				end
			end
			-- 洗切对方的额外卡组。
			Duel.ShuffleExtra(1-tp)
		end
	end
end
-- 过滤函数：判断某卡是否带有本次临时除外的对应标记fid，用于结束阶段筛选需要返回的卡。
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 结束阶段处理：按fid筛选出之前临时除外的卡组，一并送回持有者卡组并洗切。
function s.retop2(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local tg=e:GetLabelObject():Filter(s.retfilter,nil,fid)
	-- 将筛选出的临时除外的卡组以效果原因送回持有者卡组并洗切。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
