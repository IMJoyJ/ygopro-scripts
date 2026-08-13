--ペンギン勇士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，把这张卡作为同调素材的场合，不是水属性怪兽的同调召唤不能使用。
-- ①：自己场上有怪兽被盖放的场合才能发动。这张卡从手卡特殊召唤。那之后，可以让这张卡的等级下降1星或者2星。
-- ②：以自己场上1只里侧守备表示怪兽为对象才能发动。那只怪兽变成表侧守备表示。这个效果把「企鹅」怪兽以外的怪兽变成表侧守备表示的场合，那个效果无效化。
function c14761450.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是水属性怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c14761450.synlimit)
	c:RegisterEffect(e1)
	-- ①：自己场上有怪兽被盖放的场合才能发动。这张卡从手卡特殊召唤。那之后，可以让这张卡的等级下降1星或者2星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14761450,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MSET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,14761450)
	e2:SetCondition(c14761450.spcon1)
	e2:SetTarget(c14761450.sptg)
	e2:SetOperation(c14761450.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetCondition(c14761450.spcon2)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c14761450.spcon2)
	c:RegisterEffect(e4)
	-- ②：以自己场上1只里侧守备表示怪兽为对象才能发动。那只怪兽变成表侧守备表示。这个效果把「企鹅」怪兽以外的怪兽变成表侧守备表示的场合，那个效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(14761450,1))
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,14761451)
	e5:SetTarget(c14761450.postg)
	e5:SetOperation(c14761450.posop)
	c:RegisterEffect(e5)
end
-- 作为同调素材的限制判定：若候选素材不是水属性，则返回 true，使这张卡不能作为非水属性同调召唤的素材。
function c14761450.synlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- ①效果的发动条件：检测本次盖放事件中是否存在自己场上的怪兽被盖放（控制者为己方的怪兽）。若存在，则条件满足，可以从手卡发动特殊召唤效果。
function c14761450.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
-- 过滤函数：判断一张卡是否为里侧表示且由自己控制，用于检测自己场上的里侧表示怪兽。
function c14761450.cfilter(c,tp)
	return c:IsFacedown() and c:IsControler(tp)
end
-- ①效果的补充发动条件：检测事件相关卡中是否存在自己控制的里侧表示怪兽，用于判断自己场上是否有怪兽以里侧表示放置、特殊召唤成功或变成里侧表示等情况。
function c14761450.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14761450.cfilter,1,nil,tp)
end
-- ①效果发动目标检查：确认自己场上主要怪兽区有空位，且这张卡在手卡可以被特殊召唤；若满足则效果可以发动。
function c14761450.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用空格，确保有特殊召唤的位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理将特殊召唤这张卡（1张，由自己处理），供连锁判定和相关卡效果参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，将其表侧攻击表示特殊召唤；成功后若等级不低于2，则让玩家选择是否下降1星或2星；若选择下降，则给这张卡附加对应的等级降低效果（持续存在于场上，离场等重置）。
function c14761450.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时判定：这张卡仍与效果关联（未被无效/离场），且特殊召唤成功，且等级≥2，才继续等级下降处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsLevelAbove(2) then
		local off=1
		local ops,opval={},{}
		ops[off]=aux.Stringid(14761450,2)  --"等级下降1星"
		opval[off]=-1
		off=off+1
		if c:IsLevelAbove(3) then
			ops[off]=aux.Stringid(14761450,3)  --"等级下降2星"
			opval[off]=-2
			off=off+1
		end
		ops[off]=aux.Stringid(14761450,4)  --"什么都不做"
		opval[off]=0
		-- 弹出选项让玩家选择：等级下降1星/等级下降2星（若等级≥3）/什么都不做；返回选项编号并用于后续处理。
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		local sel=opval[op]
		if sel==0 then return end
		-- 中断当前效果链，使特殊召唤成功后的等级下降选择作为另一次处理，确保“那之后”的时点正确，不导致错时点。
		Duel.BreakEffect()
		-- 那之后，可以让这张卡的等级下降1星或者2星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(sel)
		c:RegisterEffect(e1)
	end
end
-- ②效果的对象过滤：卡必须为里侧守备表示，并且当前可以变更表示形式（没有不能变更表示的限制）。
function c14761450.filter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsCanChangePosition()
end
-- ②效果发动目标处理：确认自己场上有符合条件的里侧守备表示怪兽；提示玩家选择，并将选择的1只怪兽作为效果对象，同时设置操作信息为变更表示形式。
function c14761450.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14761450.filter(chkc) end
	-- 发动合法性检查：自己场上是否存在至少1只符合条件的里侧守备表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c14761450.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示提示信息“请选择要改变表示形式的怪兽”，用于选择对象时的界面引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从自己场上选择1只符合条件的里侧守备表示怪兽，并登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c14761450.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次效果将变更表示形式，对象为选择的怪兽，数量1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果处理：取对象怪兽，若其仍与效果关联且尚未变为表侧守备表示，则将其变为表侧守备表示；若该怪兽不是「企鹅」怪兽，则对其适用效果无效化（怪兽效果无效+效果发动无效）。
function c14761450.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第1个效果对象卡（即②效果选择的那只里侧守备表示怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsPosition(POS_FACEUP_DEFENSE) then
		-- 将对象怪兽的表示形式变更为表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		if tc:IsPosition(POS_FACEUP_DEFENSE) and not tc:IsSetCard(0x5a) then
			local c=e:GetHandler()
			-- 这个效果把「企鹅」怪兽以外的怪兽变成表侧守备表示的场合，那个效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 那个效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
	end
end
