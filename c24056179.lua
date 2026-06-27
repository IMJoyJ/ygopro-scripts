--カプセル・モンスター・チェス
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的主要阶段才能发动。以自己墓地1只怪兽为对象才能发动。那只怪兽在持有者的魔法与陷阱区域表侧表示当作永续魔法卡使用放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段，把我方场上1张原本是怪兽卡的卡送去墓地才能发动。从卡组把和那张卡原本的属性·种族相同、且原本等级高1到3级的1只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤可以放置到魔陷区域的怪兽
function s.filter(c,tp)
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(c:GetOwner()) then r=LOCATION_REASON_CONTROL end
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner())
		-- 检查怪兽是否在墓地且其拥有者有空的魔陷区域
		and c:IsFaceupEx() and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE,tp,r)>0
end
-- 放置效果的条件检查与锁定
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,tp) end
	-- 确认墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 锁定墓地的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 声明怪兽离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 放置效果的实际操作：将怪兽移动至魔陷区并变更为永续魔法
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e)
		-- 将怪兽表侧表示放置到魔法与陷阱区域并确认是否成功
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 设置该卡片的类型为永续魔法
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 特殊召唤的触发条件：必须在自己的结束阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 过滤作为Cost送墓的场上原本是怪兽的卡
function s.cfilter(c,e,tp)
	return c:IsFaceupEx() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
		-- 检查卡片原始等级是否大于0，且卡组中存在可以特殊召唤的符合条件怪兽
		and c:GetOriginalLevel()>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,c,e,tp)
		-- 检查将卡片送墓后是否能腾出怪兽区域位置
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特召怪兽过滤：卡组中比Cost卡原始等级高1到3级，且属性和种族均相同的怪兽
function s.spfilter(c,tc,e,tp)
	local lv=c:GetOriginalLevel()-tc:GetOriginalLevel()
	return lv>0 and lv<4
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤的Cost：将我方场上1张原本是怪兽的卡送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以支付特召Cost的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 提示选择送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择我方场上1张符合条件的卡片作为代价
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 将选中的卡片送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 特殊召唤效果的条件确认
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 声明从卡组特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的实际操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=e:GetLabelObject()
	-- 提示选择特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
