--幻獣機コルトウィング
-- 效果：
-- ①：自己场上有其他的「幻兽机」怪兽存在，这张卡特殊召唤成功的场合发动。在自己场上把2只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
-- ②：这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
-- ③：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。
-- ④：1回合1次，把自己场上2只衍生物解放，以对方场上1张卡为对象才能发动。那张对方的卡破坏并除外。
function c94973028.initial_effect(c)
	-- ②：这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c94973028.lvval)
	c:RegisterEffect(e1)
	-- ③：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置效果适用条件为自己场上存在衍生物
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ①：自己场上有其他的「幻兽机」怪兽存在，这张卡特殊召唤成功的场合发动。在自己场上把2只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(94973028,0))  --"特殊召唤Token"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c94973028.spcon)
	e4:SetTarget(c94973028.sptg)
	e4:SetOperation(c94973028.spop)
	c:RegisterEffect(e4)
	-- ④：1回合1次，把自己场上2只衍生物解放，以对方场上1张卡为对象才能发动。那张对方的卡破坏并除外。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(94973028,1))  --"破坏并除外"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCost(c94973028.descost)
	e5:SetTarget(c94973028.destg)
	e5:SetOperation(c94973028.desop)
	c:RegisterEffect(e5)
end
-- 计算等级上升数值的辅助函数
function c94973028.lvval(e,c)
	local tp=c:GetControler()
	-- 获取自己场上所有「幻兽机衍生物」的等级合计值
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 过滤自己场上表侧表示的「幻兽机」怪兽
function c94973028.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x101b)
end
-- 特殊召唤成功时效果的发动条件判定函数
function c94973028.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除自身以外的其他「幻兽机」怪兽
	return Duel.IsExistingMatchingCard(c94973028.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 特殊召唤效果的目标确定与效果分类声明函数
function c94973028.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息，声明该效果包含产生2只衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置连锁信息，声明该效果包含特殊召唤2只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 特殊召唤效果的执行函数
function c94973028.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上的怪兽区域空余位置是否小于等于1，若是则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	-- 检查玩家是否具有特殊召唤该「幻兽机衍生物」的权限
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 在系统后台创建第一只「幻兽机衍生物」的卡片数据
		local token=Duel.CreateToken(tp,94973029)
		-- 以表侧表示特殊召唤第一只衍生物的中间步骤
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 在系统后台创建第二只「幻兽机衍生物」的卡片数据
		token=Duel.CreateToken(tp,94973029)
		-- 以表侧表示特殊召唤第二只衍生物的中间步骤
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 完成所有放入特殊召唤步骤的怪兽的特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
-- 破坏效果的发动代价（Cost）处理函数
function c94973028.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少2只可以解放的衍生物
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,2,nil,TYPE_TOKEN) end
	-- 让玩家选择自己场上的2只衍生物作为解放对象
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,2,2,nil,TYPE_TOKEN)
	-- 将选中的2只衍生物解放作为发动的代价
	Duel.Release(g,REASON_COST)
end
-- 过滤可以被除外的卡片
function c94973028.desfilter(c)
	return c:IsAbleToRemove()
end
-- 破坏并除外效果的目标选择与效果分类声明函数
function c94973028.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c94973028.desfilter(chkc) end
	-- 检查对方场上是否存在至少1张可以成为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(c94973028.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张满足条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c94973028.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁信息，声明该效果包含破坏选定卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息，声明该效果包含除外选定卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 破坏并除外效果的执行函数
function c94973028.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡片因效果破坏并移动到除外区
		Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
	end
end
