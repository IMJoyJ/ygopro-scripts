--寄生虫パラノイド
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。这张卡从手卡当作装备卡使用给那只怪兽装备。装备怪兽种族变成昆虫族，不能向昆虫族怪兽攻击，昆虫族怪兽为对象发动的装备怪兽的效果无效化。这个效果在对方回合也能发动。
-- ②：当作装备卡使用的这张卡被送去墓地的场合才能发动。从手卡把1只7星以上的昆虫族怪兽无视召唤条件特殊召唤。
function c14457896.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。这张卡从手卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14457896,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,14457896)
	e1:SetTarget(c14457896.eqtg)
	e1:SetOperation(c14457896.eqop)
	c:RegisterEffect(e1)
	-- ②：当作装备卡使用的这张卡被送去墓地的场合才能发动。从手卡把1只7星以上的昆虫族怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14457896,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c14457896.spcon)
	e2:SetTarget(c14457896.sptg)
	e2:SetOperation(c14457896.spop)
	c:RegisterEffect(e2)
end
-- 效果处理函数，用于处理装备效果的发动条件判断
function c14457896.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查玩家场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在至少1只表侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择场上1只表侧表示的怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数，用于处理装备效果的发动执行
function c14457896.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁中被选择的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查是否满足装备条件（区域不足、目标怪兽里侧、目标怪兽无效）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 设置装备卡只能装备给特定怪兽的限制
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c14457896.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 使装备怪兽种族变为昆虫族
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_INSECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 使装备怪兽不能向昆虫族怪兽攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetValue(c14457896.atlimit)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	-- 判断当前是否为攻击阶段且攻击怪兽为目标怪兽
	if tc==Duel.GetAttacker() then
		local bc=tc:GetBattleTarget()
		if bc~=nil and bc:IsFaceup() and bc:IsRace(RACE_INSECT) then
			-- 无效此次攻击
			Duel.NegateAttack()
		end
	end
	-- 设置一个持续效果，当有以昆虫族怪兽为对象的装备怪兽效果发动时，该效果无效
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetLabelObject(tc)
	e4:SetCondition(c14457896.discon)
	e4:SetOperation(c14457896.disop)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e4)
end
-- 装备限制判断函数，判断是否为装备目标怪兽
function c14457896.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 攻击限制判断函数，判断目标是否为昆虫族且表侧表示
function c14457896.atlimit(e,c)
	return c:IsRace(RACE_INSECT) and c:IsFaceup()
end
-- 用于判断连锁中是否有昆虫族怪兽被选为目标
function c14457896.disfilter(c,re)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsRelateToEffect(re)
end
-- 连锁无效条件判断函数，判断是否为针对装备怪兽的连锁
function c14457896.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local rc=re:GetHandler()
	if not tc or rc~=tc then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断目标卡片组中是否存在昆虫族怪兽且该连锁可被无效
	return g and g:IsExists(c14457896.disfilter,1,nil,re) and Duel.IsChainNegatable(ev)
end
-- 连锁无效处理函数，使连锁效果无效
function c14457896.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使指定连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 特殊召唤发动条件判断函数，判断装备卡是否从魔法陷阱区送入墓地
function c14457896.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget()
end
-- 特殊召唤过滤函数，筛选7星以上昆虫族怪兽
function c14457896.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsLevelAbove(7) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤发动条件判断函数，用于判断是否满足特殊召唤条件
function c14457896.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c14457896.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果处理函数，用于处理特殊召唤效果的发动执行
function c14457896.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c14457896.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
