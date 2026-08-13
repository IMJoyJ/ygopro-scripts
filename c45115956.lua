--戦華史略－矯詔之叛
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只「战华」怪兽特殊召唤，自己受到那只怪兽的等级×100伤害。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以场上1只「战华」怪兽为对象才能发动。那只怪兽的属性变更为任意属性。以对方场上的怪兽为对象发动的场合，可以再得到那只怪兽的控制权。
local s,id,o=GetID()
-- 初始化效果注册：e1为魔法卡发动所需的ACTIVATE效果；e2注册①效果（起动，魔陷区，1回合1次，手牌特召「战华」并自伤）；e3注册②效果（起动，取对象，1回合1次，送墓自身为代价，变更属性并可获得控制权）。
function c45115956.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从手卡把1只「战华」怪兽特殊召唤，自己受到那只怪兽的等级×100伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45115956,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,45115956)
	e2:SetTarget(c45115956.sptg)
	e2:SetOperation(c45115956.spop)
	c:RegisterEffect(e2)
	-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以场上1只「战华」怪兽为对象才能发动。那只怪兽的属性变更为任意属性。以对方场上的怪兽为对象发动的场合，可以再得到那只怪兽的控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45115956,1))  --"改变属性"
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,45115956+o)
	e3:SetCost(c45115956.attcost)
	e3:SetTarget(c45115956.atttg)
	e3:SetOperation(c45115956.attop)
	c:RegisterEffect(e3)
end
-- 特殊召唤的过滤条件：手卡中存在「战华」字段（0x137）且可以被当前效果特殊召唤的怪兽。
function c45115956.spfilter(c,e,tp)
	return c:IsSetCard(0x137) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果（起动效果，主要阶段）的发动条件检查：自己怪兽区有空位，且手牌存在满足条件的「战华」怪兽。
function c45115956.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌是否存在至少1只满足spfilter过滤条件的「战华」怪兽。
		and Duel.IsExistingMatchingCard(c45115956.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果信息：本次效果包含特殊召唤，预计从手牌特殊召唤1只怪兽（对象不确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置效果信息：本次效果包含造成伤害，伤害数值根据后续特殊召唤的怪兽等级确定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0)
end
-- ①效果处理：从手牌选择1只符合条件的「战华」怪兽表侧攻击表示特殊召唤，成功时给予自己其等级×100的伤害。
function c45115956.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上仍有空位，否则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示特殊召唤的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只满足spfilter条件的「战华」怪兽。
	local g=Duel.SelectMatchingCard(tp,c45115956.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选中的怪兽成功特殊召唤到自己场上，则执行后续伤害。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 对自己造成该怪兽等级×100的效果伤害。
		Duel.Damage(tp,tc:GetLevel()*100,REASON_EFFECT)
	end
end
-- ②效果的发动代价：将魔法与陷阱区域表侧表示的这张卡送入墓地。
function c45115956.attcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡作为代价送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 对象过滤条件：场上表侧表示且字段为「战华」的怪兽。
function c45115956.attfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- ②效果的目标指定：选择场上1只表侧表示的「战华」怪兽为对象，并记录其当前控制者用于后续判断。
function c45115956.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c45115956.attfilter(chkc) end
	-- 检查场上是否存在可作为对象的表侧「战华」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c45115956.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择表侧表示怪兽的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示的「战华」怪兽作为对象，并将其与效果建立联系。
	local tc=Duel.SelectTarget(tp,c45115956.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	e:SetLabel(tc:GetControler())
end
-- ②效果处理：对象合法且不免疫时，宣言一个与当前属性不同的属性并变更其属性；若对象是对方场上的怪兽，则追加询问是否获得控制权。
function c45115956.attop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 显示宣言属性的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		local catt=tc:GetAttribute()
		-- 让发动玩家从除当前属性以外的属性中宣言1个属性。
		local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~catt)
		-- 那只怪兽的属性变更为任意属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if e:GetLabel()==1-tp and tc:IsControler(1-tp) and tc:IsControlerCanBeChanged()
			-- 若对象是对方场上的怪兽且其控制权可被变更，询问玩家是否获得控制权。
			and Duel.SelectYesNo(tp,aux.Stringid(45115956,2)) then  --"是否获得控制权？"
			-- 中断当前效果，使后续获得控制权的处理与之前的属性变更处理分开（避免错过时点）。
			Duel.BreakEffect()
			-- 让发动玩家获得该怪兽的控制权。
			Duel.GetControl(tc,tp)
		end
	end
end
