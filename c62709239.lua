--幻影騎士団ブレイクソード
-- 效果：
-- 3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
-- ②：超量召唤的这张卡被破坏的场合，以自己墓地2只相同等级的「幻影骑士团」怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽的等级上升1星。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
function c62709239.initial_effect(c)
	-- 为这张卡添加超量召唤手续：需要2只等级3的怪兽叠放作为超量素材（对应召唤条件“3星怪兽×2”）。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62709239,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c62709239.descost)
	e1:SetTarget(c62709239.destg)
	e1:SetOperation(c62709239.desop)
	c:RegisterEffect(e1)
	-- ②：超量召唤的这张卡被破坏的场合，以自己墓地2只相同等级的「幻影骑士团」怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽的等级上升1星。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62709239,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c62709239.spcon)
	e2:SetTarget(c62709239.sptg)
	e2:SetOperation(c62709239.spop)
	c:RegisterEffect(e2)
end
-- 发动代价处理：cost检查阶段确认可以移除1个超量素材，实际发动时移除这张卡的1个超量素材作为代价。
function c62709239.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 取对象效果的发动条件与目标选择：确认自己场上和对方场上各存在至少1张能成为对象的卡，且不能选择已经作为对象的卡（chkc时返回false）。
function c62709239.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1张可被选择为对象的卡（aux.TRUE表示所有场上卡均可）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在至少1张可被选择为对象的卡。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家发出选择提示，要求其选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1张卡作为效果对象（同时将此卡登记为连锁对象）。
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 再次提示选择要破坏的卡，这次用于选择对方场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为效果对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置本连锁的操作信息：将选出的2张卡作为破坏对象，效果分类为破坏（CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果处理：取出连锁的全部对象卡，过滤出仍与该效果相关的卡，若存在则将其全部破坏。
function c62709239.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中的对象卡片组（即发动时选择的那2张卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将过滤后的对象卡以效果破坏（送入墓地）。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡被破坏，且被破坏前所在位置是怪兽区，并且该卡曾以超量召唤的方式召唤过（即“超量召唤的这张卡被破坏的场合”）。
function c62709239.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 选择第一只墓地怪兽的过滤器：必须是等级大于0的「幻影骑士团」怪兽，且可以被特殊召唤，并且墓地还存在另一只同等级的「幻影骑士团」怪兽可以一并特殊召唤。
function c62709239.spfilter1(c,e,tp)
	return c:GetLevel()>0 and c:IsSetCard(0x10db) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认墓地存在另一只与第一只等级相同、属于「幻影骑士团」且可特殊召唤的怪兽。
		and Duel.IsExistingTarget(c62709239.spfilter2,tp,LOCATION_GRAVE,0,1,c,c:GetLevel(),e,tp)
end
-- 选择第二只墓地怪兽的过滤器：必须与第一只等级相同，属于「幻影骑士团」系列，且可以被特殊召唤。
function c62709239.spfilter2(c,lv,e,tp)
	return c:IsLevel(lv) and c:IsSetCard(0x10db) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动与取目标处理：检查不受禁止同时特殊召唤2只以上的效果影响（此处对应青眼精灵龙），且自己有足够的怪兽区空格，且墓地存在符合条件的对象，然后选择2只对象。
function c62709239.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己的主要怪兽区空格数量大于1，确保能特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认墓地中存在符合条件的第一只怪兽（即存在可作为对象的目标）。
		and Duel.IsExistingTarget(c62709239.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家发出选择提示，要求其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择第一只符合条件的「幻影骑士团」怪兽作为特殊召唤对象。
	local g1=Duel.SelectTarget(tp,c62709239.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc1=g1:GetFirst()
	-- 再次提示选择要特殊召唤的第二张卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择第二只符合条件的「幻影骑士团」怪兽，其等级必须与第一只相同。
	local g2=Duel.SelectTarget(tp,c62709239.spfilter2,tp,LOCATION_GRAVE,0,1,1,tc1,tc1:GetLevel(),e,tp)
	g1:Merge(g2)
	-- 设置本连锁的操作信息：将选出的2只怪兽作为特殊召唤对象，效果分类为特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- ②效果处理：根据主怪兽区空格数判断能否召唤，过滤仍相关的对象，依次特殊召唤并给每只怪兽附加等级+1效果，最后完成特殊召唤；随后给发动玩家设置回合结束前非暗属性不能特殊召唤的自肃。
function c62709239.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家主要怪兽区的可用空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁处理中的对象卡片组（选中的2只墓地怪兽）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	local ct=g:GetCount()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>0 and ct<=ft and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		local tc=g:GetFirst()
		while tc do
			-- 将对象怪兽以表侧攻击表示逐个特殊召唤（特殊召唤步骤）。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽的等级上升1星。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
		-- 完成特殊召唤处理，将上述特殊召唤步骤整体结算。
		Duel.SpecialSummonComplete()
	end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c62709239.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给发动玩家：直到回合结束时，自己不能特殊召唤非暗属性怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃的判定函数：当怪兽的属性不是暗属性（ATTRIBUTE_DARK）时返回true，表示该怪兽不能被特殊召唤。
function c62709239.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
