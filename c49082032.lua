--リサーガム・エクシーズ
-- 效果：
-- ①：自己场上的超量怪兽的攻击力上升800。
-- ②：1回合1次，从手卡丢弃1张魔法卡，以自己场上1只超量怪兽为对象才能发动。和那只自己怪兽相同种族而阶级高1阶的1只「混沌No.」怪兽或者「混沌超量」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。把「升阶魔法」魔法卡以外丢弃发动的场合，这个效果特殊召唤的怪兽在结束阶段回到持有者的额外卡组。
function c49082032.initial_effect(c)
	-- ①：自己场上的超量怪兽的攻击力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前发动或适用
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从手卡丢弃1张魔法卡，以自己场上1只超量怪兽为对象才能发动。和那只自己怪兽相同种族而阶级高1阶的1只「混沌No.」怪兽或者「混沌超量」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。把「升阶魔法」魔法卡以外丢弃发动的场合，这个效果特殊召唤的怪兽在结束阶段回到持有者的额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 筛选场上的超量怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_XYZ))
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从手卡丢弃1张魔法卡，以自己场上1只超量怪兽为对象才能发动。和那只自己怪兽相同种族而阶级高1阶的1只「混沌No.」怪兽或者「混沌超量」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。把「升阶魔法」魔法卡以外丢弃发动的场合，这个效果特殊召唤的怪兽在结束阶段回到持有者的额外卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49082032,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c49082032.spcost)
	e3:SetTarget(c49082032.sptg)
	e3:SetOperation(c49082032.spop)
	c:RegisterEffect(e3)
end
-- 过滤手牌中可丢弃的魔法卡
function c49082032.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 丢弃手牌中的魔法卡作为发动代价
function c49082032.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的手牌
	if chk==0 then return Duel.IsExistingMatchingCard(c49082032.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择一张手牌丢弃
	local g=Duel.SelectMatchingCard(tp,c49082032.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetFirst():IsSetCard(0x95) then e:SetLabel(1) end
	-- 将选中的手牌送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 筛选场上的超量怪兽作为效果对象
function c49082032.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查目标怪兽是否满足成为超量素材的条件
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查是否有符合条件的额外卡组怪兽可以特殊召唤
		and Duel.IsExistingMatchingCard(c49082032.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRace(),c:GetRank()+1)
end
-- 筛选可特殊召唤的「混沌No.」或「混沌超量」怪兽
function c49082032.spfilter2(c,e,tp,mc,race,rk)
	return c:IsRace(race) and c:IsRank(rk) and c:IsSetCard(0x1048,0x1073) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否能被特殊召唤且场上空间足够
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 选择效果的对象怪兽
function c49082032.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c49082032.spfilter1(chkc,e,tp) end
	-- 检查是否有满足条件的场上的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c49082032.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上的超量怪兽作为对象
	Duel.SelectTarget(tp,c49082032.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果发动后的操作
function c49082032.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否满足成为超量素材的条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的额外卡组怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c49082032.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRace(),tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标怪兽的叠放卡叠放到新召唤的怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放到新召唤的怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将符合条件的怪兽从额外卡组特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		if e:GetLabel()~=1 then
			local c=e:GetHandler()
			local fid=c:GetFieldID()
			sc:RegisterFlagEffect(49082032,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 注册结束阶段返回额外卡组的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(sc)
			e1:SetCondition(c49082032.retcon)
			e1:SetOperation(c49082032.retop)
			-- 将效果注册到玩家全局环境
			Duel.RegisterEffect(e1,tp)
		end
		sc:CompleteProcedure()
	end
end
-- 判断是否满足返回额外卡组的条件
function c49082032.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(49082032)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 将怪兽送回额外卡组
function c49082032.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将怪兽送回玩家卡组
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
