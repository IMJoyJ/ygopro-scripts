--幻獣機ドラゴサック
-- 效果：
-- 7星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。在自己场上把2只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
-- ②：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。
-- ③：1回合1次，把自己场上1只「幻兽机」怪兽解放，以场上1张卡为对象才能发动。那张卡破坏。这个效果发动的回合，这张卡不能攻击。
function c22110647.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为7、数量为2的怪兽作为素材进行XYZ召唤
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- 只要自己场上有衍生物存在，这张卡不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 判断场上是否存在衍生物作为效果发动条件
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。在自己场上把2只「幻兽机衍生物」特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(22110647,0))  --"在自己场上把2只「幻兽机衍生物」特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c22110647.spcost)
	e4:SetTarget(c22110647.sptg)
	e4:SetOperation(c22110647.spop)
	c:RegisterEffect(e4)
	-- ③：1回合1次，把自己场上1只「幻兽机」怪兽解放，以场上1张卡为对象才能发动。那张卡破坏。这个效果发动的回合，这张卡不能攻击
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(22110647,1))  --"选择场上1张卡破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1)
	e5:SetCost(c22110647.descost)
	e5:SetTarget(c22110647.destg)
	e5:SetOperation(c22110647.desop)
	c:RegisterEffect(e5)
end
-- 支付1个超量素材作为费用
function c22110647.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 判断是否满足特殊召唤衍生物的条件
function c22110647.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 判断是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 设置操作信息，表示将特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息，表示将特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 执行特殊召唤衍生物的操作
function c22110647.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	-- 判断是否可以特殊召唤衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建一只幻兽机衍生物
		local token1=Duel.CreateToken(tp,22110648)
		-- 将第一只衍生物特殊召唤
		Duel.SpecialSummonStep(token1,0,tp,tp,false,false,POS_FACEUP)
		-- 创建第二只幻兽机衍生物
		local token2=Duel.CreateToken(tp,22110648)
		-- 将第二只衍生物特殊召唤
		Duel.SpecialSummonStep(token2,0,tp,tp,false,false,POS_FACEUP)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 支付解放幻兽机怪兽作为费用
function c22110647.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0
		-- 判断场上是否有可解放的幻兽机怪兽
		and Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x101b) end
	-- 选择1只幻兽机怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x101b)
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
	-- 使此卡在本回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 判断是否满足破坏场上卡的条件
function c22110647.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判断场上是否有至少2张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)>1
		-- 判断场上是否有可破坏的目标卡
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示将破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作
function c22110647.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
