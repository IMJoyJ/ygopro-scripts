--春化精の暦替
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「春化精」怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
-- ②：自己手卡是0张的场合，对方回合，把墓地的这张卡除外才能发动。从自己墓地把「春化精」怪兽尽可能特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽在自己结束阶段回到持有者手卡。这个效果在这张卡送去墓地的回合不能发动。
function c37313338.initial_effect(c)
	-- “这个卡名的①②的效果1回合各能使用1次。①：以自己墓地1只「春化精」怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。” 本段代码实现①效果。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,37313338)
	e1:SetTarget(c37313338.target)
	e1:SetOperation(c37313338.activate)
	c:RegisterEffect(e1)
	-- “②：自己手卡是0张的场合，对方回合，把墓地的这张卡除外才能发动。从自己墓地把「春化精」怪兽尽可能特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽在自己结束阶段回到持有者手卡。这个效果在这张卡送去墓地的回合不能发动。” 本段代码实现②效果。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,37313339)
	e2:SetCondition(c37313338.spcon)
	-- 设置②效果的发动代价为把墓地中的这张卡除外，使用辅助函数aux.bfgcost作为cost。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c37313338.sptg)
	e2:SetOperation(c37313338.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果的对象筛选条件：自己墓地的「春化精」怪兽，且该怪兽能够加入手卡或能够被特殊召唤（需有可用怪兽区且可特殊召唤）。
function c37313338.filter(c,e,tp)
	return c:IsSetCard(0x182) and c:IsType(TYPE_MONSTER)
		-- 判断怪兽是否满足“加入手卡或特殊召唤”的条件：能加入手卡，或者（自己场上有空余怪兽区且能够被特殊召唤）。
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ①效果的发动时点处理：确认可取对象后，让玩家从自己墓地选择1只符合条件的「春化精」怪兽作为效果对象。
function c37313338.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37313338.filter(chkc,e,tp) end
	-- 发动合法性检查：确认自己墓地存在至少1只符合条件的「春化精」怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c37313338.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送选择对象的提示消息，界面显示“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地选择1只符合条件的「春化精」怪兽作为效果对象，并与此效果建立对象联系。
	local g=Duel.SelectTarget(tp,c37313338.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
-- ①效果处理：若对象仍与效果相关，则在王家长眠之谷等干扰检查通过后，根据情况选择“加入手卡”或“特殊召唤”其中之一执行。
function c37313338.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象卡（应为①效果选择的那只墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 若对象卡受到王家长眠之谷影响且当前连锁可被无效，则使该效果发动无效并中止处理。
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 若对象卡不满足“不受王家长眠之谷影响”的条件（即因王谷而无法移动），则中止效果处理。
		if not aux.NecroValleyFilter()(tc) then return end
		-- 判断自己场上是否有空余怪兽区，且该对象怪兽是否能够被特殊召唤，以决定是否可以选择特殊召唤处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 且（该对象不能加入手卡，或玩家在选项中选择“特殊召唤”）时，进入特殊召唤分支；否则执行加入手卡分支。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将对象怪兽表侧表示特殊召唤到自己的主要怪兽区。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将对象怪兽加入其持有者的手卡，原因记为效果。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件判定：仅在对方回合、自己手卡为0张、且不处于这张卡送去墓地的回合时，才允许发动。
function c37313338.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体发动条件：当前不是自己的回合（即对方回合）、自己手牌数为0、且满足aux.exccon（即不是本回合送去墓地，或有返回/除外等例外）。
	return Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and aux.exccon(e)
end
-- 定义②效果特殊召唤的筛选条件：墓地的「春化精」怪兽，并且能够被特殊召唤。
function c37313338.spfilter(c,e,tp)
	return c:IsSetCard(0x182) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动时点处理：确认有可用怪兽区且墓地存在至少1只符合条件的「春化精」怪兽，并设置操作信息。
function c37313338.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己场上存在可用的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且墓地存在至少1只满足特殊召唤条件的「春化精」怪兽。
		and Duel.IsExistingMatchingCard(c37313338.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 预设操作信息，表示该效果在墓地执行特殊召唤，数量预计为1（实际按尽可能多特召）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：获取可用怪兽数量和墓地符合条件的「春化精」怪兽组（排除王谷影响），根据空格数和同名卡最多1张限制选择尽可能多的怪兽进行特殊召唤，并为特召成功的怪兽标记，随后设置结束阶段回手的效果。
function c37313338.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上可用的主要怪兽区数量，作为可特殊召唤数量的上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取墓地中所有满足特殊召唤条件且不受王家长眠之谷影响的「春化精」怪兽集合。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c37313338.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=math.min(g:GetClassCount(Card.GetCode),ft)
	-- 给玩家发送选择特殊召唤卡的提示消息，界面显示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从符合条件的怪兽中选择一组卡名互不相同、数量为ct的怪兽作为实际特殊召唤对象（ct为可用格子和不同卡名数的最小值）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	if not sg then return end
	local fid=e:GetHandler():GetFieldID()
	local tc=sg:GetFirst()
	while tc do
		-- 逐步特殊召唤每张选中的怪兽；若成功特殊召唤，则给该怪兽注册一个标识标记，用于结束阶段识别。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			tc:RegisterFlagEffect(37313338,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		end
		tc=sg:GetNext()
	end
	-- 完成所有特殊召唤步骤，结束连锁中的特殊召唤处理。
	Duel.SpecialSummonComplete()
	sg:KeepAlive()
	-- “这个效果特殊召唤的怪兽在自己结束阶段回到持有者手卡。” 本段代码实现结束阶段回收怪兽的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(sg)
	e1:SetCondition(c37313338.thcon)
	e1:SetOperation(c37313338.thop)
	-- 将这个结束阶段回手牌的持续效果注册到场上，使该效果在对应结束阶段时点执行。
	Duel.RegisterEffect(e1,tp)
end
-- 判断卡片是否带有指定的fid标识，用于筛选出本次②效果特殊召唤的怪兽。
function c37313338.thfilter(c,fid)
	return c:GetFlagEffectLabel(37313338)==fid
end
-- 回手效果的触发条件：仅在自己结束阶段且仍有带对应fid标识的怪兽存在时返回true；若已没有则清除保存的卡片组并重置效果。
function c37313338.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是该效果的控制者（即不是自己的结束阶段）时，不触发回手效果。
	if Duel.GetTurnPlayer()~=tp then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(c37313338.thfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 回手效果处理：取出所有带对应标识的怪兽，将它们一并加入持有者手卡。
function c37313338.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c37313338.thfilter,nil,e:GetLabel())
	-- 将这些怪兽加入其持有者的手卡，原因记为效果（REASON_EFFECT）。
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
end
