--X－セイバー ペリナ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，把这张卡送去墓地才能发动。从卡组把「X-剑士 佩里娜」以外的2只「X-剑士」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
-- ②：这张卡作为「X-剑士」同调怪兽的同调素材送去墓地的场合才能发动。从以下选1个适用。
-- ●那只怪兽在同1次的战斗阶段中可以作2次攻击。
-- ●那只怪兽可以直接攻击。
local s,id,o=GetID()
-- 定义并注册本卡的全部效果：①在召唤·特殊召唤成功时，可将自身送墓发动，从卡组特殊召唤2只其他「X-剑士」怪兽，并在结束阶段将其破坏；②作为「X-剑士」同调素材送墓时，可让那只同调怪兽获得2次攻击或直接攻击能力；①②效果各1回合1次。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，把这张卡送去墓地才能发动。从卡组把「X-剑士 佩里娜」以外的2只「X-剑士」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡作为「X-剑士」同调怪兽的同调素材送去墓地的场合才能发动。从以下选1个适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"赋予效果"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.eacon)
	e3:SetTarget(s.eatg)
	e3:SetOperation(s.eaop)
	c:RegisterEffect(e3)
end
-- 作为①效果发动的代价：先检查这张卡能否作为代价送入墓地；可以时，把这张卡送去墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡自身送入墓地，支付①效果的发动代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选条件：要特殊召唤的怪兽必须属于「X-剑士」系列（0x100d）、卡名不是「X-剑士 佩里娜」、并且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x100d) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：主阶空位至少2个、没有受到青眼精灵龙效果影响（不能同时特殊召唤2只以上）、卡组中存在至少2张满足条件的「X-剑士」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区是否至少有2个可用空格，用来容纳将要特殊召唤的2只怪兽。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查卡组中是否存在至少2只符合s.spfilter条件的「X-剑士」怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 将此连锁的处理信息登记为：从卡组特殊召唤2只怪兽（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ①效果处理：在仍有至少2个空位且未被青眼精灵龙限制时，从卡组选择2只符合条件的「X-剑士」怪兽，以表侧表示特殊召唤；同时为它们设置标记，并注册在结束阶段将其破坏的延迟效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选出2张满足条件的「X-剑士」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,2,2,nil,e,tp)
		if g:GetCount()>0 then
			local fid=c:GetFieldID()
			-- 遍历已选出的怪兽组，对每张怪兽依次进行特殊召唤处理。
			for tc in aux.Next(g) do
				-- 将当前这张怪兽以表侧攻击表示特殊召唤到自己的怪兽区（作为多张同时特殊召唤的一步）。
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			end
			-- 结束多张特殊召唤的连锁处理，统一触发特殊召唤成功时的诱发效果。
			Duel.SpecialSummonComplete()
			g:KeepAlive()
			-- 这个效果特殊召唤的怪兽在结束阶段破坏。②：这张卡作为「X-剑士」同调怪兽的同调素材送去墓地的场合才能发动。从以下选1个适用。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(g)
			e1:SetCondition(s.descon)
			e1:SetOperation(s.desop)
			-- 将该结束阶段破坏效果作为全局领域效果注册到决斗环境中。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 判断卡片是否带有本卡①效果赋予的标识（fid），用于识别通过该效果特殊召唤的怪兽。
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 结束阶段时检查被标记的怪兽是否仍存在；若已不存在，则释放保存的怪兽组并重置效果，否则继续执行破坏。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else
		return true
	end
end
-- 执行破坏操作：将所有仍带有该标识的、由①效果特殊召唤的怪兽破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示本卡（X-剑士 佩里娜）的卡图，提示玩家这是其①效果的结束阶段破坏处理。
	Duel.Hint(HINT_CARD,0,id)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	-- 将这些被标记的怪兽以效果破坏（REASON_EFFECT）送入墓地。
	Duel.Destroy(tg,REASON_EFFECT)
end
-- ②效果的发动条件：这张卡位于墓地，且是作为「X-剑士」同调怪兽的同调素材被送去墓地。
function s.eacon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsSetCard(0x100d)
end
-- ②效果的发动目标判定：取得那张同调怪兽，确认这张卡确实在其素材中且该怪兽是以同调召唤方式出场，然后将它设为对象。
function s.eatg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local sc=c:GetReasonCard()
	if chk==0 then return sc:GetMaterial():IsContains(c) and sc:IsSummonType(SUMMON_TYPE_SYNCHRO) end
	-- 将那只同调怪兽登记为当前连锁的效果对象。
	Duel.SetTargetCard(sc)
end
-- ②效果处理：让玩家在“2次攻击”和“直接攻击”中选择一项，然后给对象怪兽注册对应效果。
function s.eaop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选定对象的那只同调怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsLocation(LOCATION_MZONE) then
		-- 弹出两个选项供玩家选择：第0项为“可以作2次攻击”，第1项为“可以直接攻击”。
		local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"2次攻击/直接攻击"
		if op==0 then
			-- ●那只怪兽在同1次的战斗阶段中可以作2次攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,4))  --"可以作2次攻击（X-剑士 佩里娜）"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		else
			-- ●那只怪兽可以直接攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,5))  --"可以直接攻击（X-剑士 佩里娜）"
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
