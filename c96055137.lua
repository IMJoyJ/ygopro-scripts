--インフェルノイド・ベルフェゴル
-- 效果：
-- 这张卡不能通常召唤。自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地2只「狱火机」怪兽除外的场合才能从手卡·墓地特殊召唤。
-- ①：这张卡的攻击宣言时才能发动。对方从自身的额外卡组把1只怪兽除外。
-- ②：自己·对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
function c96055137.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地2只「狱火机」怪兽除外的场合才能从手卡·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCondition(c96055137.spcon)
	e2:SetTarget(c96055137.sptg)
	e2:SetOperation(c96055137.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击宣言时才能发动。对方从自身的额外卡组把1只怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetTarget(c96055137.rmtg1)
	e3:SetOperation(c96055137.rmop1)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCost(c96055137.rmcost2)
	e4:SetTarget(c96055137.rmtg2)
	e4:SetOperation(c96055137.rmop2)
	c:RegisterEffect(e4)
end
-- 过滤手牌、墓地中可作为特殊召唤Cost除外的「狱火机」怪兽
function c96055137.spfilter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤自己场上表侧表示的效果怪兽
function c96055137.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 获取怪兽的等级或阶级（超量怪兽返回阶级，其他怪兽返回等级）
function c96055137.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 特殊召唤规则的条件判定函数
function c96055137.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 计算自己场上所有表侧表示效果怪兽的等级·阶级合计值
	local sum=Duel.GetMatchingGroup(c96055137.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c96055137.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取手牌、墓地（若有特定卡片效果影响则包含场上）中满足条件的「狱火机」怪兽组
	local g=Duel.GetMatchingGroup(c96055137.spfilter,tp,loc,0,c)
	-- 检查是否能选出2只怪兽除外，且除外后有足够的怪兽区域空位用于特殊召唤
	return g:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 特殊召唤规则的Cost选择目标函数
function c96055137.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取可作为特殊召唤Cost除外的「狱火机」怪兽组
	local g=Duel.GetMatchingGroup(c96055137.spfilter,tp,loc,0,c)
	-- 给玩家发送提示信息：选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择2只用于特殊召唤Cost除外的怪兽，并确保特殊召唤时有足够的怪兽区域空位
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作函数
function c96055137.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽因特殊召唤原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 效果①（攻击宣言时除外对方额外卡组怪兽）的发动准备与合法性检查
function c96055137.rmtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查对方额外卡组是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
	-- 设置效果处理信息：从对方额外卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
-- 效果①（攻击宣言时除外对方额外卡组怪兽）的效果处理
function c96055137.rmop1(e,tp,eg,ep,ev,re,r,rp)
	-- 给对方玩家发送提示信息：选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让对方玩家从自身的额外卡组选择1只怪兽
	local g=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将对方选择的额外卡组怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 效果②（解放怪兽除外对方墓地卡）的发动Cost处理
function c96055137.rmcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查自己场上是否存在至少1只可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只怪兽作为解放的Cost
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 效果②（解放怪兽除外对方墓地卡）的目标选择与合法性检查
function c96055137.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 在chk为0时，检查对方墓地是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 给玩家发送提示信息：选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息：除外指定的对方墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果②（解放怪兽除外对方墓地卡）的效果处理
function c96055137.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
