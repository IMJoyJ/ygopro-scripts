--星屑の願い
-- 效果：
-- ①：1回合1次，自己场上的「星尘」同调怪兽为让自身的效果发动而被解放的场合，以那1只怪兽为对象才能发动。那只怪兽特殊召唤。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
-- ②：这张卡的①的效果特殊召唤的怪兽在攻击表示的场合不会被战斗破坏。
function c35129241.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上的「星尘」同调怪兽为让自身的效果发动而被解放的场合，以那1只怪兽为对象才能发动。那只怪兽特殊召唤。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1)
	e2:SetTarget(c35129241.target)
	e2:SetOperation(c35129241.activate)
	c:RegisterEffect(e2)
	-- ②：这张卡的①的效果特殊召唤的怪兽在攻击表示的场合不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c35129241.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的被解放的星尘同调怪兽，包括：前控制者为玩家、前位置为主怪兽区、种族为星尘、类型为同调、解放原因为代价、且该怪兽可作为效果对象并可特殊召唤。
function c35129241.filter(c,e,tp,re)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSetCard(0xa3) and c:IsType(TYPE_SYNCHRO) and c:IsReason(REASON_COST) and c==re:GetHandler()
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：存在符合条件的被解放怪兽且玩家场上存在空位。
function c35129241.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return eg:IsExists(c35129241.filter,1,nil,e,tp,re)
		-- 判断玩家场上是否存在空位以确保能特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local tg
	if #eg==1 then
		tg=eg:Clone()
	else
		-- 提示玩家选择效果的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tg=eg:FilterSelect(tp,c35129241.filter,1,1,nil,e,tp,re)
	end
	-- 设置当前连锁的目标卡为选定的怪兽。
	Duel.SetTargetCard(tg)
	-- 设置操作信息为特殊召唤目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,0,0)
	-- 设置连锁限制，仅允许发动者自身连锁此效果。
	Duel.SetChainLimit(c35129241.chlimit)
end
-- 连锁限制函数，确保只有发动者可以连锁此效果。
function c35129241.chlimit(e,ep,tp)
	return tp==ep
end
-- 发动效果：获取目标怪兽并将其特殊召唤，若成功则为其注册标记以供后续效果识别。
function c35129241.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍存在于场上并执行特殊召唤操作。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		tc:RegisterFlagEffect(35129241,RESET_EVENT+RESETS_STANDARD,0,1,e:GetHandler():GetFieldID())
	end
end
-- 判断目标怪兽是否处于攻击表示且拥有特定标记以触发不被战斗破坏效果。
function c35129241.indtg(e,c)
	return c:IsAttackPos() and c:GetFlagEffectLabel(35129241)==e:GetHandler():GetFieldID()
end
