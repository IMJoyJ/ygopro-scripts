--マーシャリング・フィールド
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己不是机械族怪兽不能特殊召唤。
-- ②：1回合1次，宣言5～9的任意等级才能发动。自己场上的全部5星以上的机械族怪兽变成宣言的等级。
-- ③：自己场上的机械族超量怪兽被破坏的场合，可以作为代替把这张卡送去墓地。
-- ④：这张卡从场上送去墓地的场合才能发动。从自己的卡组·墓地选1张「升阶魔法-紧急型混沌之力」加入手卡。
function c63881033.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己不是机械族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c63881033.splimit)
	c:RegisterEffect(e2)
	-- ②：1回合1次，宣言5～9的任意等级才能发动。自己场上的全部5星以上的机械族怪兽变成宣言的等级。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63881033,0))  --"等级变化"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetTarget(c63881033.lvtg)
	e3:SetOperation(c63881033.lvop)
	c:RegisterEffect(e3)
	-- ③：自己场上的机械族超量怪兽被破坏的场合，可以作为代替把这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(c63881033.reptg)
	e4:SetValue(c63881033.repval)
	e4:SetOperation(c63881033.repop)
	c:RegisterEffect(e4)
	-- ④：这张卡从场上送去墓地的场合才能发动。从自己的卡组·墓地选1张「升阶魔法-紧急型混沌之力」加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(63881033,3))  --"加入手卡"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCondition(c63881033.thcon)
	e5:SetTarget(c63881033.thtg)
	e5:SetOperation(c63881033.thop)
	c:RegisterEffect(e5)
end
-- 限制玩家不能特殊召唤机械族以外的怪兽
function c63881033.splimit(e,c)
	return c:GetRace()~=RACE_MACHINE
end
-- 过滤场上表侧表示的5星以上的机械族怪兽
function c63881033.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsRace(RACE_MACHINE)
end
-- 等级变化效果的靶向与发动准备，让玩家宣言5至9的等级并记录
function c63881033.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的5星以上的机械族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c63881033.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择要变化的等级”
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(63881033,1))  --"请选择要变化的等级"
	-- 让玩家宣言一个5到9之间的等级
	local lv=Duel.AnnounceLevel(tp,5,9)
	e:SetLabel(lv)
end
-- 等级变化效果的处理，将符合条件的怪兽等级变更为宣言的等级
function c63881033.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有表侧表示的5星以上的机械族怪兽
	local g=Duel.GetMatchingGroup(c63881033.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部5星以上的机械族怪兽变成宣言的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 过滤自己场上因战斗或效果破坏的表侧表示的机械族超量怪兽
function c63881033.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的靶向与发动准备，检查是否有符合条件的怪兽将被破坏且本卡未确定被破坏
function c63881033.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c63881033.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏的适用对象
function c63881033.repval(e,c)
	return c63881033.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理，将这张卡送去墓地
function c63881033.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
-- 检查这张卡是否从场上送去墓地
function c63881033.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组或墓地中的「升阶魔法-紧急型混沌之力」
function c63881033.thfilter(c)
	return c:IsCode(94220427) and c:IsAbleToHand()
end
-- 检索效果的靶向与发动准备，检查卡组或墓地中是否存在目标卡并设置操作信息
function c63881033.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地中是否存在可以加入手牌的「升阶魔法-紧急型混沌之力」
	if chk==0 then return Duel.IsExistingMatchingCard(c63881033.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息为将1张卡从卡组或墓地加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索效果的处理，从卡组或墓地选择1张「升阶魔法-紧急型混沌之力」加入手牌
function c63881033.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地中选择1张「升阶魔法-紧急型混沌之力」（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c63881033.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
