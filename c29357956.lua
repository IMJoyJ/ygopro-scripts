--剣闘獣ネロキウス
-- 效果：
-- 「剑斗兽」怪兽×3
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡不会被战斗破坏，这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到额外卡组才能发动。从卡组把2只「剑斗兽」怪兽特殊召唤。
function c29357956.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册融合召唤手续：以3只满足「剑斗兽」字段的怪兽为融合素材进行融合召唤（不需要融合魔法）。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1019),3,true)
	-- 注册接触融合的召唤手续：将己方场上可作为额外卡组代价的「剑斗兽」怪兽送回卡组，从额外卡组特殊召唤这张卡；素材只取己方主要怪兽区。
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_MZONE,0,aux.ContactFusionSendToDeck(c))
	-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c29357956.splimit)
	c:RegisterEffect(e1)
	-- 这张卡不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(1)
	e4:SetCondition(c29357956.actcon)
	c:RegisterEffect(e4)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到额外卡组才能发动。从卡组把2只「剑斗兽」怪兽特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(29357956,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c29357956.spcon)
	e6:SetCost(c29357956.spcost)
	e6:SetTarget(c29357956.sptg)
	e6:SetOperation(c29357956.spop)
	c:RegisterEffect(e6)
end
-- 限制这张卡只能从额外卡组特殊召唤：若自身当前位置不是额外卡组，则不允许将其特殊召唤。
function c29357956.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 判断这张卡是否正在进行战斗：当前攻击怪兽或攻击对象若为此卡则返回真。
function c29357956.actcon(e)
	-- 判断当前攻击怪兽或攻击对象是否为此卡，用于确定这张卡参与了战斗。
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- ②效果的发动条件：这张卡在本战斗阶段进行过战斗（战斗过的怪兽数量大于0）。
function c29357956.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- ②效果的发动代价：将此卡返回额外卡组；检查时确认可以作为额外卡组代价，发动时将其返回额外卡组（卡组顶端）作为Cost。
function c29357956.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 以Cost形式将这张卡送去持有者额外卡组（置于卡组顶端），完成返回额外卡组的代价。
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤函数：选择卡组中带「剑斗兽」字段且可以被效果特殊召唤的怪兽。
function c29357956.filter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标：确认己方主要怪兽区至少有空位（若此卡不在额外怪兽区则额外+1）、对方未适用青眼精灵龙的限制，且卡组存在至少2只可特殊召唤的「剑斗兽」怪兽；满足后登记特殊召唤2只的操作信息。
function c29357956.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得tp玩家主要怪兽区当前可用的空格数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ft>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 同时确认卡组中存在至少2张满足过滤条件的「剑斗兽」怪兽供特殊召唤。
			and Duel.IsExistingMatchingCard(c29357956.filter,tp,LOCATION_DECK,0,2,nil,e,tp)
	end
	-- 向系统登记本次效果处理包含特殊召唤2只怪兽，目标区域为持有者卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果的实际处理：若场上仍无青眼精灵龙限制且主要怪兽区至少2个空位，就从卡组选出2只「剑斗兽」怪兽，依次特殊召唤到场上，并给它们注册同名标记，最后完成特殊召唤流程。
function c29357956.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次确认主要怪兽区可用空格不少于2，否则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 从卡组获取所有满足『剑斗兽』字段且可特殊召唤的怪兽集合。
	local g=Duel.GetMatchingGroup(c29357956.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 弹出选择提示，让玩家选择要特殊召唤的2只「剑斗兽」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		local tc=sg:GetFirst()
		-- 将选中的第1只「剑斗兽」怪兽以表侧攻击表示特殊召唤，并为其注册一个以原卡号为编码的标记（随离场等标准重置）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		tc=sg:GetNext()
		-- 将选中的第2只「剑斗兽」怪兽以表侧攻击表示特殊召唤，并为其注册一个以原卡号为编码的标记（随离场等标准重置）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 完成这一组特殊召唤处理，统一触发特殊召唤成功时的时点效果。
		Duel.SpecialSummonComplete()
	end
end
