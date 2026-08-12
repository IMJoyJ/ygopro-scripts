--GP－PB
-- 效果：
-- 「黄金荣耀-滚球手」＋「黄金荣耀」怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡融合召唤的场合才能发动（自己基本分比对方少的场合，这个效果的发动和效果不会被无效化）。把最多有那个作为融合素材的数量的对方场上的表侧表示怪兽当作装备魔法卡使用给这张卡装备。
-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-滚球手」特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤限制并注册三个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为92003832的怪兽和满足过滤条件的怪兽作为融合素材
	aux.AddFusionProcCodeFunRep(c,92003832,aux.FilterBoolFunction(Card.IsFusionSetCard,0x192),1,127,true,true)
	-- ①：这张卡融合召唤的场合才能发动（自己基本分比对方少的场合，这个效果的发动和效果不会被无效化）。把最多有那个作为融合素材的数量的对方场上的表侧表示怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- 当LP少于对方时，使①效果的发动和效果不会被无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(0xff)
	e2:SetLabelObject(e1)
	e2:SetOperation(s.adjustop)
	c:RegisterEffect(e2)
	-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-滚球手」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 调整阶段时检查玩家LP，若低于对方则修改①效果属性
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	-- 判断当前玩家LP是否低于对方LP
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) then
		e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CAN_FORBIDDEN)
	else
		e1:SetProperty(EFFECT_FLAG_DELAY)
	end
end
-- 效果发动条件：此卡为融合召唤成功
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤函数：选择场上正面表示且能改变控制权的怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- ①效果的发动条件检查：确认融合素材数量大于0且场上装备区有空位
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetMaterialCount()
	-- 检查融合素材数量大于0且场上装备区有空位
	if chk==0 then return ct>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 装备限制函数：限制装备卡只能被此卡装备
function s.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end
-- ①效果的处理：选择对方场上怪兽作为装备卡装备给此卡
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetMaterialCount()
	-- 获取玩家场上装备区可用空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的怪兽数量不超过装备区空位和融合素材数量的最小值
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,math.min(ft,ct),nil)
	if #g==0 then return end
	-- 遍历选择的怪兽进行装备操作
	for tc in aux.Next(g) do
		-- 执行装备操作
		if Duel.Equip(tp,tc,c,true,true) then
			-- 设置装备卡的装备限制效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			tc:RegisterEffect(e1,true)
		end
	end
	-- 完成装备过程
	Duel.EquipComplete()
end
-- ②效果的发动条件：确认①效果已发动
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- ②效果的目标设定：将此卡送回额外卡组并特殊召唤1只「黄金荣耀-滚球手」
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将此卡送回额外卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置从卡组·墓地特殊召唤1只「黄金荣耀-滚球手」的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 过滤函数：选择卡号为92003832且可特殊召唤的怪兽
function s.sfilter(c,e,tp)
	return c:IsCode(92003832) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的处理：将此卡送回额外卡组并从卡组·墓地特殊召唤1只「黄金荣耀-滚球手」
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡与效果相关且成功送回额外卡组
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)>0
		-- 确认场上存在空位可特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的「黄金荣耀-滚球手」
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选择的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
