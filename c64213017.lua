--騎甲虫隊戦術機動
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「骑甲虫」怪兽为对象才能发动。那只怪兽特殊召唤，自己失去那只怪兽的原本攻击力数值的基本分。这个效果特殊召唤的怪兽在这个回合不能攻击。
-- ②：自己场上的表侧表示的昆虫族怪兽被战斗·效果破坏的场合才能发动。在自己场上把1只「骑甲虫衍生物」（昆虫族·地·3星·攻/守1000）特殊召唤。
function c64213017.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：以自己墓地1只「骑甲虫」怪兽为对象才能发动。那只怪兽特殊召唤，自己失去那只怪兽的原本攻击力数值的基本分。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,64213017)
	e1:SetTarget(c64213017.sptg)
	e1:SetOperation(c64213017.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的表侧表示的昆虫族怪兽被战斗·效果破坏的场合才能发动。在自己场上把1只「骑甲虫衍生物」（昆虫族·地·3星·攻/守1000）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,64213018)
	e2:SetCondition(c64213017.condition)
	e2:SetTarget(c64213017.target)
	e2:SetOperation(c64213017.operation)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地可以特殊召唤的「骑甲虫」怪兽
function c64213017.filter(c,e,tp)
	return c:IsSetCard(0x170) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域空格并选择墓地的「骑甲虫」怪兽作为对象
function c64213017.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c64213017.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「骑甲虫」怪兽
		and Duel.IsExistingTarget(c64213017.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「骑甲虫」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c64213017.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤分类的操作信息，包含目标怪兽组和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：特殊召唤目标怪兽，使其本回合不能攻击，并扣除自身等同于该怪兽原本攻击力的生命值
function c64213017.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 尝试将目标怪兽以表侧表示特殊召唤到自己场上
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。自己失去那只怪兽的原本攻击力数值的基本分。②：自己场上的表侧表示的昆虫族怪兽被战斗·效果破坏的场合才能发动。在自己场上把1只「骑甲虫衍生物」（昆虫族·地·3星·攻/守1000）特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的流程处理
	Duel.SpecialSummonComplete()
	-- 扣除玩家等同于特殊召唤怪兽原本攻击力数值的生命值
	Duel.SetLP(tp,Duel.GetLP(tp)-tc:GetBaseAttack())
end
-- 过滤自己场上因战斗或效果被破坏的表侧表示昆虫族怪兽
function c64213017.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsRace(RACE_INSECT)
end
-- 检查是否有符合条件的昆虫族怪兽被破坏，作为效果②的发动条件
function c64213017.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c64213017.cfilter,1,nil,tp)
end
-- 效果②的发动准备：检查怪兽区域空格并确认是否可以特殊召唤衍生物
function c64213017.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤符合特定属性、种族、攻守和等级的「骑甲虫衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,64213018,0x170,TYPES_TOKEN_MONSTER,1000,1000,3,RACE_INSECT,ATTRIBUTE_EARTH) end
	-- 设置产生衍生物分类的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤分类的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果②的效果处理：在自己场上特殊召唤1只「骑甲虫衍生物」
function c64213017.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否没有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查是否无法特殊召唤「骑甲虫衍生物」，若无法特殊召唤则不处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,64213018,0x170,TYPES_TOKEN_MONSTER,1000,1000,3,RACE_INSECT,ATTRIBUTE_EARTH) then return end
	-- 创建「骑甲虫衍生物」的卡片数据对象
	local tk=Duel.CreateToken(tp,64213018)
	-- 将创建的衍生物以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP)
end
