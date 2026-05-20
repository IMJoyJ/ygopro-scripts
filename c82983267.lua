--ピュアリィープ！？
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「纯爱妖精」超量怪兽为对象才能发动。和那只自己怪兽阶级不同的1只「纯爱妖精」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段回到持有者的额外卡组。
-- ②：把墓地的这张卡除外，以自己墓地最多3只「纯爱妖精」怪兽为对象才能发动。那些怪兽回到卡组。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（场上「纯爱妖精」超量怪兽升阶超量召唤）和②效果（墓地除外让最多3只「纯爱妖精」怪兽回到卡组）
function s.initial_effect(c)
	-- ①：以自己场上1只「纯爱妖精」超量怪兽为对象才能发动。和那只自己怪兽阶级不同的1只「纯爱妖精」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段回到持有者的额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地最多3只「纯爱妖精」怪兽为对象才能发动。那些怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置效果②的发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数1：筛选自己场上表侧表示的、可以作为超量素材的「纯爱妖精」超量怪兽，且额外卡组存在至少1只与其阶级不同、可以重叠在其上方进行超量召唤的「纯爱妖精」超量怪兽
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x18c) and c:IsType(TYPE_XYZ)
		-- 检查该怪兽是否满足必须作为超量素材的限制条件
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在至少1只满足过滤条件2（阶级不同且可重叠超量召唤）的怪兽
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank())
end
-- 过滤函数2：筛选额外卡组中与目标怪兽阶级不同、属于「纯爱妖精」系列、是超量怪兽、能以目标怪兽为素材进行超量召唤，且能被特殊召唤到额外怪兽区域或有连接端指向的怪兽
function s.filter2(c,e,tp,mc,rk)
	return not c:IsRank(rk) and c:IsSetCard(0x18c) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否能以超量召唤的方式特殊召唤，且在将目标怪兽作为素材时，额外卡组怪兽的特殊召唤区域是否有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果①的发动准备与目标选择函数，用于确认是否满足发动条件、选择场上的「纯爱妖精」超量怪兽作为对象，并声明特殊召唤的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	-- 检查自己场上是否存在至少1只满足过滤条件1的「纯爱妖精」超量怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)end
	-- 提示玩家选择作为效果对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只满足过滤条件1的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的处理函数，将额外卡组阶级不同的「纯爱妖精」超量怪兽重叠在对象怪兽上方当作超量召唤特殊召唤，并注册下个回合结束阶段回到额外卡组的延迟效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽在效果处理时是否仍满足必须作为超量素材的限制条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
		or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp)
		or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足过滤条件2（与对象怪兽阶级不同）的「纯爱妖精」超量怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将原对象怪兽持有的超量素材转移给新特殊召唤的超量怪兽
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将原对象怪兽重叠在新特殊召唤的超量怪兽下方作为其超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新超量怪兽以表侧表示当作超量召唤特殊召唤，若特殊召唤成功则进行后续处理
		if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
			sc:CompleteProcedure()
		end
		-- 这个效果特殊召唤的怪兽在下个回合的结束阶段回到持有者的额外卡组。②：把墓地的这张卡除外，以自己墓地最多3只「纯爱妖精」怪兽为对象才能发动。那些怪兽回到卡组。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 将当前回合数记录在效果的Label中，以便后续判断是否到了“下个回合”
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetLabelObject(sc)
		e1:SetCondition(s.tdcon3)
		e1:SetOperation(s.tdop3)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将该延迟效果注册给玩家，使其在后续的回合结束阶段触发
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟效果的触发条件函数：必须不是发动效果的当回合，且特殊召唤的怪兽仍带有对应的标记
function s.tdcon3(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 检查当前回合数不等于发动回合数（即至少到了下个回合），且目标怪兽身上的标记依然存在
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(id)~=0
end
-- 延迟效果的处理函数：展示卡片动画，并将特殊召唤的怪兽送回持有者的额外卡组
function s.tdop3(e,tp,eg,ep,ev,re,r,rp)
	-- 在屏幕上展示本卡（纯爱妖精跳越！？）的卡片发动动画，提示玩家正在处理其后续效果
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	-- 将目标怪兽送回持有者的额外卡组
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 过滤函数：筛选自己墓地中可以回到卡组的「纯爱妖精」怪兽
function s.drfilter(c)
	return c:IsSetCard(0x18c) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果②的发动准备与目标选择函数，用于确认是否满足发动条件、选择墓地最多3只「纯爱妖精」怪兽作为对象，并声明回卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.drfilter(chkc) end
	-- 检查自己墓地是否存在至少1只满足过滤条件的「纯爱妖精」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.drfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要回到卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1到3只墓地的「纯爱妖精」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.drfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置连锁信息，表明该效果包含将选择的卡片送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的处理函数，将选择的墓地怪兽送回持有者的卡组并洗牌
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择且当前仍与该连锁相关的对象怪兽
	local tg=Duel.GetTargetsRelateToChain()
	if #tg==0 then return end
	-- 将这些对象怪兽送回持有者的卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
