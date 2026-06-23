--戦華史略－矯詔之叛
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只「战华」怪兽特殊召唤，自己受到那只怪兽的等级×100伤害。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以场上1只「战华」怪兽为对象才能发动。那只怪兽的属性变更为任意属性。以对方场上的怪兽为对象发动的场合，可以再得到那只怪兽的控制权。
local s,id,o=GetID()
-- 注册卡牌的初始化效果，包括允许发动的空效果、特殊召唤效果和改变属性效果
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
-- 过滤函数，用于判断手牌中是否存在满足条件的「战华」怪兽
function c45115956.spfilter(c,e,tp)
	return c:IsSetCard(0x137) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤效果的发动条件
function c45115956.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断目标玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断目标玩家手牌中是否存在满足条件的「战华」怪兽
		and Duel.IsExistingMatchingCard(c45115956.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息，表示将要造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0)
end
-- 执行特殊召唤效果的操作函数
function c45115956.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断目标玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示目标玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「战华」怪兽
	local g=Duel.SelectMatchingCard(tp,c45115956.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤操作并返回成功召唤的怪兽数量
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 对发动者造成伤害，伤害值为特殊召唤怪兽的等级乘以100
		Duel.Damage(tp,tc:GetLevel()*100,REASON_EFFECT)
	end
end
-- 支付效果费用，将自身送去墓地
function c45115956.attcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为支付效果费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于判断场上是否存在满足条件的「战华」怪兽
function c45115956.attfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 判断是否满足改变属性效果的发动条件
function c45115956.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c45115956.attfilter(chkc) end
	-- 判断目标玩家场上是否存在满足条件的「战华」怪兽
	if chk==0 then return Duel.IsExistingTarget(c45115956.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示目标玩家选择要改变属性的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的「战华」怪兽作为目标
	local tc=Duel.SelectTarget(tp,c45115956.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	e:SetLabel(tc:GetControler())
end
-- 执行改变属性效果的操作函数
function c45115956.attop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示目标玩家选择要宣言的属性
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		local catt=tc:GetAttribute()
		-- 让目标玩家从可选属性中宣言一个属性
		local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~catt)
		-- 创建改变属性的效果并注册到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if e:GetLabel()==1-tp and tc:IsControler(1-tp) and tc:IsControlerCanBeChanged()
			-- 询问目标玩家是否获得目标怪兽的控制权
			and Duel.SelectYesNo(tp,aux.Stringid(45115956,2)) then  --"是否获得控制权？"
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将目标怪兽的控制权转移给发动者
			Duel.GetControl(tc,tp)
		end
	end
end
