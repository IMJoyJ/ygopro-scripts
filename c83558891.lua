--肆世壊の新星
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己墓地1只「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：自己场上的「恐吓爪牙族」连接怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c83558891.initial_effect(c)
	-- 在卡片中注册记载了「维萨斯-斯塔弗罗斯特」的卡名
	aux.AddCodeList(c,56099748)
	-- ①：以自己墓地1只「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c83558891.target)
	e1:SetOperation(c83558891.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「恐吓爪牙族」连接怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,83558891)
	e2:SetTarget(c83558891.reptg)
	e2:SetValue(c83558891.repval)
	e2:SetOperation(c83558891.repop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地中可以守备表示特殊召唤的「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」
function c83558891.filter(c,e,tp)
	return (c:IsSetCard(0x17a) or c:IsCode(56099748)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与对象选择判定
function c83558891.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c83558891.filter(chkc,e,tp) end
	-- 判定当前自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在满足特殊召唤条件的对象
		and Duel.IsExistingTarget(c83558891.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c83558891.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息，表示该效果包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的实际效果处理（特殊召唤对象怪兽）
function c83558891.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤条件：自己场上因战斗或效果被破坏的「恐吓爪牙族」连接怪兽
function c83558891.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x17a) and c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的触发判定与玩家意向确认
function c83558891.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c83558891.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定需要代替破坏的具体卡片是否符合过滤条件
function c83558891.repval(e,c)
	return c83558891.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的实际处理（将墓地的这张卡除外）
function c83558891.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
