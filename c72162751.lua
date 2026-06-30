--陽炎殿の君主
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以包含表侧表示的魔法·陷阱卡的自己场上最多2张卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。这个效果破坏的卡是1张的场合，这张卡在下个回合的结束阶段回到手卡。2张的场合，这张卡得到以下效果。
-- ●只要这张卡在怪兽区域存在，从场上送去对方墓地的怪兽不去墓地而除外。
-- ②：场上的这张卡不会被效果破坏。
local s,id,o=GetID()
-- 卡片效果的初始化函数
function s.initial_effect(c)
	-- ②：场上的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：以包含表侧表示的魔法·陷阱卡的自己场上最多2张卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。
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
-- 过滤可以作为效果对象卡片的函数
function s.desfilter1(c,e)
	return c:IsCanBeEffectTarget(e)
end
-- 过滤表侧表示的魔法·陷阱卡
function s.desfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 检查选择的卡中是否包含表侧表示的魔法·陷阱卡，且破坏后是否有可用的怪兽区域
function s.fselect(g,tp)
	-- 判断选择的卡中是否存在表侧表示的魔法·陷阱卡，且自己怪兽区域是否有空余
	return g:IsExists(s.desfilter2,1,nil) and Duel.GetMZoneCount(tp,g)>0
end
-- 效果①的发动准备与对象选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上可以作为效果对象的卡片
	local g=Duel.GetMatchingGroup(s.desfilter1,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return g:CheckSubGroup(s.fselect,1,2,tp) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,1,2,tp)
	-- 将选中的卡片作为当前连锁的对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息：将选中的对象卡片破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	-- 设置操作信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的生效处理，破坏卡片并特殊召唤自身，根据破坏张数赋予后续或永续效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关且不受王家长眠之谷影响的被选择卡片
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	-- 破坏选择的卡片，并检查破坏数量是否不为0
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取实际被破坏的卡片数量
		local ct=Duel.GetOperatedGroup():GetCount()
		local c=e:GetHandler()
		-- 检查自己场上是否没有空余的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then
			-- 由于场上无可用区域，将这张卡送去墓地
			Duel.SendtoGrave(c,REASON_EFFECT)
		end
		if not c:IsRelateToChain() then return end
		-- 特殊召唤这张卡并检查是否成功
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			if ct==1 then
				c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))  --"只把1张卡破坏"
				-- 这个效果破坏的卡是1张的场合，这张卡在下个回合的结束阶段回到手卡。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetCountLimit(1)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				-- 设置回到手卡的时点为下个回合的结束阶段
				e1:SetLabel(Duel.GetTurnCount()+1)
				e1:SetLabelObject(e:GetHandler())
				e1:SetCondition(s.thcon)
				e1:SetOperation(s.thop)
				-- 将回到手卡的效果作为玩家的效果进行全局注册
				Duel.RegisterEffect(e1,tp)
			else
				-- 2张的场合，这张卡得到以下效果。●只要这张卡在怪兽区域存在，从场上送去对方墓地的怪兽不去墓地而除外。
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
-- 限制从场上送去对方墓地的怪兽不去墓地而除外的过滤函数
function s.rmtg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer() and c:IsLocation(LOCATION_ONFIELD) and c:IsType(TYPE_MONSTER)
end
-- 判断是否到了效果设定的下个回合结束阶段且这张卡仍存在相关标记
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		-- 判断当前回合数是否为效果设定的回合数
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 在下个回合结束阶段将怪兽送回手卡的处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将特殊召唤的这张卡送回手卡
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
