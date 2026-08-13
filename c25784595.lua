--ボーン・デーモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，从自己的手卡·场上把这张卡以外的1张卡送去墓地才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是龙族·暗属性同调怪兽不能从额外卡组特殊召唤。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。从手卡·卡组把1只恶魔族调整送去墓地，作为对象的怪兽的等级上升或下降1星。
local s,id,o=GetID()
-- 初始化函数，为『白骨恶魔』注册两个效果：e1为①效果（手卡·墓地发动，送1卡为代价特殊召唤自身），e2为②效果（场上发动，取对象并送恶魔族调整以改变等级）。
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，从自己的手卡·场上把这张卡以外的1张卡送去墓地才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只表侧表示怪兽为对象才能发动。从手卡·卡组把1只恶魔族调整送去墓地，作为对象的怪兽的等级上升或下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 定义代价过滤函数：候选卡必须能作为代价送去墓地，且其离开后己方场上仍有空位可特殊召唤白骨恶魔。
function s.costfilter(c,tp)
	-- 判断候选卡可作为代价送去墓地，并且该卡离开后己方场上仍存在可用的怪兽区域。
	return c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的代价函数：确认存在可送墓的卡后，选择一张手卡·场上的其他卡送去墓地作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动代价的合法性检查：己方手卡·场上是否存在1张（除了自身）满足代价过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp) end
	-- 向玩家发出选择要送去墓地的卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方手卡·场上选择1张满足代价过滤条件的卡作为发动代价（不能选自身）。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	-- 将选中的卡作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的目标函数：确认白骨恶魔自身可以被特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的特殊召唤操作信息，预告将把白骨恶魔特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：特殊召唤白骨恶魔，并给发动者附加“龙族·暗属性同调怪兽以外不能从额外卡组特殊召唤”的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将白骨恶魔以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- ①：这个效果的发动后，直到回合结束时自己不是龙族·暗属性同调怪兽不能从额外卡组特殊召唤。②：以自己场上1只表侧表示怪兽为对象才能发动。从手卡·卡组把1只恶魔族调整送去墓地，作为对象的怪兽的等级上升或下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将自肃效果作为影响己方玩家的领域效果注册到场上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定：额外卡组中不是“龙族·暗属性·同调”的怪兽不能特殊召唤。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
		and not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO))
end
-- ②效果的对象过滤：选择己方场上表侧表示且等级≥1的怪兽作为对象。
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- ②效果送墓过滤：从手卡·卡组选择恶魔族调整且能送去墓地的卡。
function s.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER) and c:IsAbleToGrave()
end
-- ②效果的目标/发动条件函数：确认场上存在表侧表示怪兽可作为对象，且手卡·卡组存在可送去墓地的恶魔族调整。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查己方场上是否存在至少1只表侧表示且等级≥1的怪兽，可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查己方手卡·卡组是否存在至少1只恶魔族调整怪兽，可被送去墓地。
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 向玩家发出选择表侧表示怪兽的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择己方场上1只表侧表示且等级≥1的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次效果将把1张手卡·卡组的恶魔族调整送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：从手卡·卡组选1只恶魔族调整送去墓地，若成功且对象仍适用，则让对象怪兽的等级上升或下降1星。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取手卡·卡组中所有满足条件的恶魔族调整怪兽。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if #g==0 then return end
	-- 向玩家发出选择要送去墓地的卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tg=g:Select(tp,1,1,nil):GetFirst()
	-- 取得②效果的对象怪兽（己方场上表侧表示怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 将选中的恶魔族调整送去墓地，并确认送墓成功、该调整在墓地、对象怪兽仍在场且与效果关联。
	if Duel.SendtoGrave(tg,REASON_EFFECT)>0 and tg:IsLocation(LOCATION_GRAVE)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local sel=0
		local lvl=1
		if tc:IsLevel(1) then
			-- 当对象怪兽等级为1时，只能选择“等级上升”（避免降到0以下）。
			sel=Duel.SelectOption(tp,aux.Stringid(id,1))  --"等级上升"
		else
			-- 让玩家选择“等级上升”或“等级下降”。
			sel=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"等级上升/等级下降"
		end
		if sel==1 then
			lvl=-1
		end
		-- 作为对象的怪兽的等级上升或下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lvl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
