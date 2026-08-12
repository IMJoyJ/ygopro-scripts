--春化精の暦替
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「春化精」怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
-- ②：自己手卡是0张的场合，对方回合，把墓地的这张卡除外才能发动。从自己墓地把「春化精」怪兽尽可能特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽在自己结束阶段回到持有者手卡。这个效果在这张卡送去墓地的回合不能发动。
function c37313338.initial_effect(c)
	-- ①：以自己墓地1只「春化精」怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,37313338)
	e1:SetTarget(c37313338.target)
	e1:SetOperation(c37313338.activate)
	c:RegisterEffect(e1)
	-- ②：自己手卡是0张的场合，对方回合，把墓地的这张卡除外才能发动。从自己墓地把「春化精」怪兽尽可能特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽在自己结束阶段回到持有者手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,37313339)
	e2:SetCondition(c37313338.spcon)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c37313338.sptg)
	e2:SetOperation(c37313338.spop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的墓地「春化精」怪兽，可加入手卡或特殊召唤
function c37313338.filter(c,e,tp)
	return c:IsSetCard(0x182) and c:IsType(TYPE_MONSTER)
		-- 满足条件的怪兽可特殊召唤或加入手卡
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 设置效果目标为满足条件的墓地「春化精」怪兽
function c37313338.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37313338.filter(chkc,e,tp) end
	-- 检查是否有满足条件的墓地「春化精」怪兽
	if chk==0 then return Duel.IsExistingTarget(c37313338.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的墓地「春化精」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c37313338.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
-- 处理效果的发动与执行
function c37313338.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查目标怪兽是否受王家长眠之谷影响
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 检查目标怪兽是否受王家长眠之谷影响
		if not aux.NecroValleyFilter()(tc) then return end
		-- 检查是否有足够的场上空间进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 选择特殊召唤或加入手卡
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将目标怪兽特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将目标怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- 设置效果发动条件
function c37313338.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合不是自己且手卡为0张且此卡未在送去墓地的回合
	return Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and aux.exccon(e)
end
-- 过滤满足条件的墓地「春化精」怪兽
function c37313338.spfilter(c,e,tp)
	return c:IsSetCard(0x182) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标
function c37313338.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的场上空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的墓地「春化精」怪兽
		and Duel.IsExistingMatchingCard(c37313338.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 处理效果的发动与执行
function c37313338.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家的场上空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取满足条件的墓地「春化精」怪兽组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c37313338.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=math.min(g:GetClassCount(Card.GetCode),ft)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽组进行特殊召唤
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	if not sg then return end
	local fid=e:GetHandler():GetFieldID()
	local tc=sg:GetFirst()
	while tc do
		-- 特殊召唤一张怪兽
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			tc:RegisterFlagEffect(37313338,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		end
		tc=sg:GetNext()
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	sg:KeepAlive()
	-- 注册结束阶段回手效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(sg)
	e1:SetCondition(c37313338.thcon)
	e1:SetOperation(c37313338.thop)
	-- 注册结束阶段回手效果
	Duel.RegisterEffect(e1,tp)
end
-- 判断怪兽是否为本次特殊召唤的怪兽
function c37313338.thfilter(c,fid)
	return c:GetFlagEffectLabel(37313338)==fid
end
-- 判断是否满足结束阶段回手条件
function c37313338.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合是否为己方回合
	if Duel.GetTurnPlayer()~=tp then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(c37313338.thfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 处理结束阶段回手效果
function c37313338.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c37313338.thfilter,nil,e:GetLabel())
	-- 将满足条件的怪兽送回手卡
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
end
