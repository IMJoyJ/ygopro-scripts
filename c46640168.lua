--刻まれし魔ラクリモーサ
-- 效果：
-- 恶魔族·光属性怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，以自己的墓地·除外状态的1只恶魔族·光属性怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降600。
-- ③：这张卡被送去墓地的场合，从自己墓地让1只其他的恶魔族·光属性怪兽回到卡组·额外卡组才能发动。给与对方1200伤害。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤限制并注册三个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足s.ffilter条件的怪兽作为素材
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- ①：这张卡融合召唤的场合，以自己的墓地·除外状态的1只恶魔族·光属性怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡或特殊召唤"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(-600)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，从自己墓地让1只其他的恶魔族·光属性怪兽回到卡组·额外卡组才能发动。给与对方1200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"给予伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.damcost)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- 过滤用于融合召唤的怪兽必须是光属性恶魔族
function s.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND)
end
-- 判断是否为融合召唤成功触发的效果
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 筛选可作为效果对象的墓地或除外状态的恶魔族光属性怪兽，满足加入手卡或特殊召唤条件
function s.filter(c,e,tp,ft)
	return c:IsFaceupEx() and c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP))
end
-- 设置①效果的目标选择逻辑，检查是否存在符合条件的卡片并提示选择
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp,ft) end
	-- 判断是否满足①效果的发动条件，即存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,ft) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽并获取其引用
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,ft):GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	end
end
-- 执行①效果的操作，根据条件将目标怪兽加入手卡或特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查目标怪兽是否受王家长眠之谷保护，若受保护则无效该效果
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 再次确认目标怪兽不受王家长眠之谷影响
		if not aux.NecroValleyFilter()(tc) then return end
		-- 判断是否有足够的怪兽区域进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
			-- 若无法加入手卡或玩家选择特殊召唤，则执行特殊召唤操作
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 执行特殊召唤操作
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 执行将目标怪兽加入手卡的操作
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- 定义用于支付③效果费用的卡片过滤条件，必须是恶魔族光属性且可送入卡组或额外卡组
function s.costfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeckOrExtraAsCost()
end
-- 设置③效果的费用支付流程，选择并送入卡组作为费用
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足③效果的发动条件，即存在符合条件的墓地怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择用于支付费用的卡片
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 显示所选卡片被选为对象的动画效果
	Duel.HintSelection(g)
	-- 将选中的卡片送入卡组并洗牌作为费用
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 设置③效果的目标信息，指定对方玩家和伤害值
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定连锁目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设定连锁目标参数为1200点伤害
	Duel.SetTargetParam(1200)
	-- 设置操作信息，记录本次效果将造成1200点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end
-- 执行③效果的操作，对对方玩家造成1200点伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成相应伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
