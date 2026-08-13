--陽炎殿の君主
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以包含表侧表示的魔法·陷阱卡的自己场上最多2张卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。这个效果破坏的卡是1张的场合，这张卡在下个回合的结束阶段回到手卡。2张的场合，这张卡得到以下效果。
-- ●只要这张卡在怪兽区域存在，从场上送去对方墓地的怪兽不去墓地而除外。
-- ②：场上的这张卡不会被效果破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册永续效果e1（这张卡不会被效果破坏）和起动效果e2（从手卡发动的破坏并特殊召唤效果，1回合只能使用1次）
function s.initial_effect(c)
	-- ②：场上的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：以包含表侧表示的魔法·陷阱卡的自己场上最多2张卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。这个卡名的①的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断该卡是否可以作为这个效果的对象
function s.desfilter1(c,e)
	return c:IsCanBeEffectTarget(e)
end
-- 过滤函数：判断该卡是否是表侧表示的魔法·陷阱卡
function s.desfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 子组选择条件：所选卡组中至少包含1张表侧表示的魔法·陷阱卡，且这些卡离场后自己场上仍有可用的怪兽区域
function s.fselect(g,tp)
	-- 要求所选卡组中至少存在1张表侧表示的魔法·陷阱卡，并且这些卡破坏离场后自己场上还有可用的怪兽区域
	return g:IsExists(s.desfilter2,1,nil) and Duel.GetMZoneCount(tp,g)>0
end
-- ①效果的目标函数：确认存在可选的对象组合且这张卡可以特殊召唤时才能发动，之后让玩家选择1～2张要破坏的卡作为对象，并设置破坏和特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检索自己场上所有可以作为这个效果对象的卡
	local g=Duel.GetMatchingGroup(s.desfilter1,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return g:CheckSubGroup(s.fselect,1,2,tp) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向玩家提示「请选择要破坏的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,1,2,tp)
	-- 把选中的卡组设置为当前连锁处理的对象
	Duel.SetTargetCard(sg)
	-- 设置连锁操作信息：将破坏选中的这些卡（数量为实际选中的张数）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	-- 设置连锁操作信息：将这张卡从手卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数：将与连锁关联的对象破坏，破坏成功后这张卡从手卡特殊召唤；根据破坏的数量是1张还是2张，分别赋予下个回合结束阶段回到手卡的效果或使对方怪兽送去墓地时除外的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本次连锁关联的对象卡，并过滤掉受王家长眠之谷影响的卡
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	-- 以效果原因破坏那些对象卡，只有实际破坏了卡才继续后续处理
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 统计实际被破坏的卡的数量
		local ct=Duel.GetOperatedGroup():GetCount()
		local c=e:GetHandler()
		-- 如果自己场上没有可用的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then
			-- 把这张卡送去墓地（没有空格特殊召唤）
			Duel.SendtoGrave(c,REASON_EFFECT)
		end
		if not c:IsRelateToChain() then return end
		-- 把这张卡从手卡以表侧表示特殊召唤，特殊召唤成功才继续后续处理
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			if ct==1 then
				c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))  --"只把1张卡破坏"
				-- 这个效果破坏的卡是1张的场合，这张卡在下个回合的结束阶段回到手卡。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetCountLimit(1)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				-- 把标签设为下个回合的回合数，用于判断回手效果的触发时点
				e1:SetLabel(Duel.GetTurnCount()+1)
				e1:SetLabelObject(e:GetHandler())
				e1:SetCondition(s.thcon)
				e1:SetOperation(s.thop)
				-- 把这个结束阶段回手的效果注册为玩家的全局效果
				Duel.RegisterEffect(e1,tp)
			else
				-- ●只要这张卡在怪兽区域存在，从场上送去对方墓地的怪兽不去墓地而除外。
				local e2=Effect.CreateEffect(c)
				e2:SetDescription(aux.Stringid(id,2))  --"得到效果"
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
				e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
				e2:SetRange(LOCATION_MZONE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(LOCATION_REMOVED)
				e2:SetTarget(s.rmtg)
				c:RegisterEffect(e2)
			end
		end
	end
end
-- 除外转移效果的作用对象：持有者是对方、从场上送去墓地的怪兽
function s.rmtg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer() and c:IsLocation(LOCATION_ONFIELD) and c:IsType(TYPE_MONSTER)
end
-- 回手效果的发动条件：这张卡仍带有「只破坏1张卡」的标记效果（否则重置该效果），且当前回合数等于记录的下个回合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		-- 只有当前回合数等于标签记录的回合数（即下个回合的结束阶段）时才满足条件
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 结束阶段回手效果的处理：把这张卡回到持有者的手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因把这张卡送去持有者的手卡
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
