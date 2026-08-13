--刻まれし魔の大聖棺
-- 效果：
-- 包含恶魔族·光属性怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己墓地的怪兽作为融合素材回到卡组，把1只恶魔族融合怪兽融合召唤。
-- ②：以连接怪兽以外的自己场上1只恶魔族·光属性怪兽为对象才能发动。从自己的场上·墓地把这张卡当作持有以下效果的装备魔法卡使用给那只自己怪兽装备。
-- ●对方不能把装备怪兽作为效果的对象。
local s,id,o=GetID()
-- 注册卡的初始效果：赋予其连接召唤手续，并注册①融合召唤与②装备两个效果，二者各1回合1次。
function s.initial_effect(c)
	-- 设置连接召唤手续：需要2只连接怪兽作为素材，且其中至少1只为恶魔族·光属性连接怪兽。
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。自己墓地的怪兽作为融合素材回到卡组，把1只恶魔族融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合效果"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以连接怪兽以外的自己场上1只恶魔族·光属性怪兽为对象才能发动。从自己的场上·墓地把这张卡当作持有以下效果的装备魔法卡使用给那只自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备效果"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 连接召唤手续的额外条件检查：所选连接素材组中至少存在1只满足s.mfilter的怪兽。
function s.lcheck(g)
	return g:IsExists(s.mfilter,1,nil)
end
-- 判断是否为连接怪兽且种族为恶魔族、属性为光属性。
function s.mfilter(c)
	return c:IsLinkRace(RACE_FIEND) and c:IsLinkAttribute(ATTRIBUTE_LIGHT)
end
-- 判断墓地怪兽是否可作为融合素材返回卡组（是怪兽且可以返回卡组）。
function s.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 判断墓地怪兽是否可作为融合素材返回卡组且不免疫此效果。
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 判断额外卡组怪兽是否为恶魔族融合怪兽，且能用给定素材组m进行融合召唤。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果的发动条件：在自己主要阶段且存在可用墓地素材（或连锁素材）进行恶魔族融合召唤时允许发动，并设置特殊召唤与回卡组的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己墓地中可作为融合素材返回卡组的怪兽集合。
		local mg1=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_GRAVE,0,nil)
		-- 检查额外卡组是否存在至少1只可用墓地素材mg1融合召唤的恶魔族融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家可用的连锁素材（替代融合素材）效果，以扩充素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查使用连锁素材提供的素材组mg3时，是否存在可融合召唤的恶魔族融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次效果将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：本次效果将把融合素材返回卡组（可能涉及手牌、场上、墓地）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- ①效果处理：选择融合怪兽及融合素材，将素材返回卡组并进行融合召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己墓地中可作为融合素材、不受王家长眠之谷影响且不免疫此效果的怪兽集合。
	local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,e)
	-- 获取使用墓地素材mg1能够融合召唤的额外卡组恶魔族融合怪兽集合。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材（替代融合素材）效果，用于扩充融合素材来源。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用连锁素材组mg3能够融合召唤的额外卡组恶魔族融合怪兽集合。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示选择要特殊召唤的卡片的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用墓地素材路线：若目标也在连锁素材路线中，则询问玩家是否使用连锁素材；选择否或不在连锁素材路线时使用墓地素材。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从墓地素材集合mg1中选择目标融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(s.fdfilter,1,nil) then
				local cg=mat1:Filter(s.fdfilter,nil)
				-- 向对方展示融合素材中来自手牌或里侧表示的怪兽卡。
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(s.gdfilter,1,nil) then
				local gg=mat1:Filter(s.gdfilter,nil)
				-- 为融合素材中来自场上表侧表示或墓地的怪兽卡高亮显示被选为素材。
				Duel.HintSelection(gg)
			end
			-- 将选中的融合素材返回持有者卡组并洗牌，原因是效果、融合素材与融合召唤。
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使随后的融合召唤视为不同时处理，避免错失时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以表侧表示特殊召唤到己方场上，特殊召唤方式为融合召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材路线时，让玩家从连锁素材集合mg3中选择目标融合怪兽所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ②效果的取对象条件：自己场上表侧表示、恶魔族、光属性、且不是连接怪兽的怪兽。
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsType(TYPE_LINK)
end
-- ②效果的发动条件与取对象：检查魔法陷阱区有空位且存在符合条件的怪兽，并选择对象。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	-- 发动条件之一：自己的魔法与陷阱区域有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件之二：自己场上有符合条件的恶魔族·光属性非连接怪兽可以作为对象。
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择要装备的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次效果将把这张卡装备给对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息：这张卡（若在墓地）将离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：将这张卡装备给目标怪兽，并注册装备限制和‘装备怪兽不能成为对方效果对象’的效果。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp) then
		-- 装备前检查：若魔陷区已无空位、目标变里侧、与效果失去联系、控制权改变或不在怪兽区，则不能装备。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or not tc:IsLocation(LOCATION_MZONE) then
			-- 装备条件不满足时将这张卡送去墓地。
			Duel.SendtoGrave(c,REASON_EFFECT)
			return
		end
		-- 尝试将这张卡作为装备卡装备给目标怪兽，失败则结束处理。
		if not Duel.Equip(tp,c,tc) then return end
		-- 从自己的场上·墓地把这张卡当作持有以下效果的装备魔法卡使用给那只自己怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- ●对方不能把装备怪兽作为效果的对象。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		-- 设置该效果的值为aux.tgoval，使‘不能成为效果对象’仅对对方玩家的效果适用。
		e2:SetValue(aux.tgoval)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制函数：这张卡只能装备给当初选择的目标怪兽。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 用于识别需要向对方确认的融合素材：素材来自场上里侧表示怪兽或手牌。
function s.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 用于识别需要高亮显示的融合素材：素材来自场上表侧表示怪兽或墓地。
function s.gdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
