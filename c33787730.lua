--ライゼオル・ホールスラスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己场上的「雷火沸动」超量怪兽数量的对方场上的表侧表示卡为对象才能发动。那些卡破坏。那之后，可以从自己墓地把1张「雷火沸动」卡作为自己场上1只4阶超量怪兽的超量素材。
-- ②：把墓地的这张卡除外才能发动。用包含「雷火沸动」怪兽的自己场上的怪兽为素材进行超量召唤。
local s,id,o=GetID()
-- 注册①和②两个效果：e1为魔法卡发动时的取对象破坏并追加叠放素材的效果，e2为墓地除外自身进行超量召唤的诱发即时效果，两者各自1回合1次。
function s.initial_effect(c)
	-- ①：以最多有自己场上的「雷火沸动」超量怪兽数量的对方场上的表侧表示卡为对象才能发动。那些卡破坏。那之后，可以从自己墓地把1张「雷火沸动」卡作为自己场上1只4阶超量怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。用包含「雷火沸动」怪兽的自己场上的怪兽为素材进行超量召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	-- 设置e2的发动COST为『把墓地的这张卡除外』（aux.bfgcost为从墓地除外自身作为COST的通用函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数s.cfilter：用于筛选自己场上表侧表示且属于「雷火沸动」字段的超量怪兽，统计其数量。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1be) and c:IsType(TYPE_XYZ)
end
-- s.target为①效果发动时的目标函数前半部分：先确认选择的对象是对方场上的表侧表示卡；然后统计自己场上「雷火沸动」超量怪兽数量作为可破坏数量上限；若数量>0且对方场上有表侧表示卡则发动合法。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 统计自己场上表侧表示的「雷火沸动」超量怪兽数量，作为①效果可选对象的数量上限。
	local gc=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return gc>0
		-- 检查对方场上是否存在至少1张表侧表示卡可以成为对象，是①效果的发动条件之一。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作者发送提示消息，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1至gc张对方场上的表侧表示卡作为对象，并把这些卡登记为本连锁的对象。
	local sg=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,gc,nil)
	-- 登记操作信息：将选定的卡片sg设为破坏对象，数量为sg的卡数，供后续效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 定义s.xyzfilter：筛选自己场上表侧表示且阶级为4的超量怪兽，并且自己墓地存在可用的「雷火沸动」素材卡，用于①效果追加处理时选择接受超量素材的怪兽。
function s.xyzfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(4)
		-- 确认自己墓地存在至少1张满足s.mtfilter且不受「王家长眠之谷」影响的「雷火沸动」卡，作为追加处理的前置条件。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,nil,e)
end
-- 定义s.mtfilter：筛选可以作为超量素材的「雷火沸动」卡，且若传入效果e会排除对该效果免疫的卡。
function s.mtfilter(c,e)
	return c:IsSetCard(0x1be)
		and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- s.activate为①效果处理：先将仍相关的对象卡破坏；若破坏成功且自己场上有符合条件的4阶超量怪兽，则询问玩家是否追加『从墓地把雷火沸动卡叠放为素材』；选择后中断时点，选择1只符合条件的超量怪兽和1张墓地雷火沸动卡，将其叠放为超量素材。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁发动时选择的对象中与效果仍存在关联的卡片（排除已离场或关系被重置的卡）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 如果存在可处理的对象且这些对象被效果成功破坏（实际破坏数量不为0），则继续执行后续追加效果。
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)~=0
		-- 追加处理前确认自己场上存在满足s.xyzfilter的超量怪兽（4阶超量且墓地有可用素材）。
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 询问玩家是否使用『从自己墓地把1张雷火沸动卡作为超量素材叠放』的追加效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否获取超量素材？"
		-- 调用Duel.BreakEffect中断当前处理，使后续的追加素材处理与破坏处理不在同一时点发生，避免错过时点。
		Duel.BreakEffect()
		-- 选择自己场上1只符合条件的4阶超量怪兽，作为追加叠放素材的对象。
		local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		local xc=g:GetFirst()
		-- 提示玩家选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从自己墓地选择1张符合条件的「雷火沸动」卡（过滤王家长眠之谷影响）作为超量素材。
		local mg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)
		if mg:GetCount()>0 then
			-- 将选择的墓地「雷火沸动」卡叠放在选择的超量怪兽下方，作为其超量素材。
			Duel.Overlay(xc,mg)
		end
	end
end
-- 定义s.filter：筛选场上表侧表示且可以作为超量素材的怪兽，用于②效果选择素材。
function s.filter(c)
	return c:IsCanOverlay() and c:IsFaceup()
end
-- s.xyztg为②效果的发动目标函数：获取场上可作为素材的怪兽，并在额外卡组中确认存在能用这些素材进行超量召唤的超量怪兽；通过后登记特殊召唤操作信息。
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有表侧表示且可以作为超量素材的怪兽，作为②效果可能使用的素材组。
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	-- 发动合法性检查：确认额外卡组中是否存在超量怪兽，能够用当前场上的素材组选出满足条件的素材进行超量召唤。
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter2,tp,LOCATION_EXTRA,0,1,nil,mg) end
	-- 登记操作信息：效果类别为特殊召唤，从额外卡组特殊召唤1只怪兽，供后续判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义s.xyzfilter2：筛选额外卡组中的超量怪兽，且当前素材组能够选出至少1组满足s.gselect的素材用于超量召唤。
function s.xyzfilter2(c,mg)
	return c:IsType(TYPE_XYZ) and mg:CheckSubGroup(s.gselect,1,#mg,c)
end
-- 定义s.gselect：判断选定素材组sg是否可以作为额外怪兽c的超量召唤素材：素材组中包含至少1只「雷火沸动」怪兽，且c可以用sg中全部怪兽进行超量召唤。
function s.gselect(sg,c)
	return sg:IsExists(Card.IsSetCard,1,nil,0x1be) and c:IsXyzSummonable(sg,#sg,#sg)
end
-- s.xyzop为②效果处理：重新取得场上素材，筛选可超量召唤的额外怪兽；玩家选择1只要超量召唤的怪兽，再选择一组包含「雷火沸动」怪兽的素材，执行超量召唤。
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取自己场上可作为超量素材的表侧怪兽。
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	-- 根据当前素材组筛选额外卡组中所有可进行超量召唤的超量怪兽。
	local exg=Duel.GetMatchingGroup(s.xyzfilter2,tp,LOCATION_EXTRA,0,nil,mg)
	if exg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的超量怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=exg:Select(tp,1,1,nil)
		-- 提示玩家选择作为超量素材的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local sg=mg:SelectSubGroup(tp,s.gselect,false,1,mg:GetCount(),tg:GetFirst())
		-- 使用选定的素材组sg对选定的额外超量怪兽执行超量召唤，素材数量固定为sg的卡数。
		Duel.XyzSummon(tp,tg:GetFirst(),sg,#sg,#sg)
	end
end
