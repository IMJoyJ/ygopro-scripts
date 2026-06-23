--デメット爺さん
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己的「珂珑公主」1个超量素材取除才能发动。从自己墓地选最多2只攻击力或守备力是0的通常怪兽作为暗属性·8星怪兽守备表示特殊召唤。
-- ②：自己的超量怪兽把作为超量素材的通常怪兽取除来让效果发动的场合，以那1只超量怪兽和对方场上1只怪兽为对象才能发动。那只对方怪兽破坏，给与对方作为对象的超量怪兽的阶级×300伤害。
function c44190146.initial_effect(c)
	-- 设置全局标记，用于监听超量素材脱离事件
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- ①：把自己的「珂珑公主」1个超量素材取除才能发动。从自己墓地选最多2只攻击力或守备力是0的通常怪兽作为暗属性·8星怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44190146,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,44190146)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c44190146.spcost)
	e1:SetTarget(c44190146.sptg)
	e1:SetOperation(c44190146.spop)
	c:RegisterEffect(e1)
	-- ②：自己的超量怪兽把作为超量素材的通常怪兽取除来让效果发动的场合，以那1只超量怪兽和对方场上1只怪兽为对象才能发动。那只对方怪兽破坏，给与对方作为对象的超量怪兽的阶级×300伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44190146,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,44190147)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c44190146.descon)
	e2:SetTarget(c44190146.destg)
	e2:SetOperation(c44190146.desop)
	c:RegisterEffect(e2)
	if not c44190146.global_check then
		c44190146.global_check=true
		-- 创建一个监听超量素材脱离事件的全局效果
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DETACH_MATERIAL)
		ge1:SetOperation(c44190146.checkop)
		-- 将该效果注册到游戏环境
		Duel.RegisterEffect(ge1,0)
		-- 创建一个监听超量素材被移除替换效果的全局效果
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
		ge2:SetCondition(c44190146.regop)
		-- 将该效果注册到游戏环境
		Duel.RegisterEffect(ge2,0)
		-- 创建一个监听连锁结束事件的全局效果
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_CHAIN_END)
		ge3:SetCondition(c44190146.clearop)
		-- 将该效果注册到游戏环境
		Duel.RegisterEffect(ge3,0)
		c44190146[0]={}
		c44190146[1]={}
	end
end
-- 处理超量素材脱离事件，记录触发效果的超量怪兽信息
function c44190146.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁序号
	local cid=Duel.GetCurrentChain()
	if cid>0 and (r&REASON_COST)>0 then
		-- 获取当前连锁触发的效果
		local te=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_EFFECT)
		local rc=te:GetHandler()
		if rc:IsRelateToEffect(te) and c44190146[1][rc]~=nil then
			local dg=c44190146[1][rc]-rc:GetOverlayGroup()
			if dg:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
				c44190146[0][rc]=rc:GetFieldID()
			end
		end
	end
	c44190146[1]={}
end
-- 处理超量素材移除替换效果，记录超量怪兽的覆盖物信息
function c44190146.regop(e,tp,eg,ep,ev,re,r,rp)
	if (r&REASON_COST)==REASON_COST and re:IsActiveType(TYPE_XYZ) then
		local rc=re:GetHandler()
		c44190146[1][rc]=rc:GetOverlayGroup()
	end
	return false
end
-- 连锁结束时清除记录的超量怪兽信息
function c44190146.clearop(e,tp,eg,ep,ev,re,r,rp)
	c44190146[0]={}
	c44190146[1]={}
end
-- 过滤函数，用于检测是否满足「珂珑公主」作为超量素材的条件
function c44190146.costfilter(c,tp)
	return c:IsCode(75574498) and c:IsFaceup() and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
-- 效果的费用支付函数，选择并移除1个「珂珑公主」超量素材
function c44190146.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「珂珑公主」超量素材
	if chk==0 then return Duel.IsExistingMatchingCard(c44190146.costfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要取除超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 选择满足条件的「珂珑公主」超量素材
	local tc=Duel.SelectMatchingCard(tp,c44190146.costfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	tc:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于检测墓地中攻击力或守备力为0的通常怪兽
function c44190146.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and (c:IsAttack(0) or c:IsDefense(0)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置特殊召唤效果的目标函数
function c44190146.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(c44190146.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果操作信息，指定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤操作，将符合条件的怪兽特殊召唤并设置等级和属性
function c44190146.spop(e,tp,eg,ep,ev,re,r,rp)
	local max=2
	-- 检查场上是否有空位
	if Duel.GetMZoneCount(tp)<1 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetMZoneCount(tp)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then max=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c44190146.filter),tp,LOCATION_GRAVE,0,1,max,nil,e,tp)
	-- 遍历选择的怪兽组
	for tc in aux.Next(g) do
		-- 特殊召唤一张怪兽
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 设置特殊召唤怪兽的等级为8
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 设置特殊召唤怪兽的属性为暗属性
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(ATTRIBUTE_DARK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断是否满足效果发动条件，即该超量怪兽是否为触发效果的怪兽
function c44190146.descon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsControler(tp) and rc:GetFieldID()==c44190146[0][rc]
end
-- 设置破坏伤害效果的目标函数
function c44190146.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rc=re:GetHandler()
	if chk==0 then return rc:IsCanBeEffectTarget(e)
		-- 检查是否有对方场上的怪兽可以作为对象
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	e:SetLabelObject(rc)
	local dmg=rc:GetRank()*300
	-- 设置当前连锁的对象为超量怪兽
	Duel.SetTargetCard(rc)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，指定将要造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
	-- 设置效果操作信息，指定将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏伤害效果，破坏对象怪兽并造成伤害
function c44190146.desop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject()
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==rc then tc=g:GetNext() end
	-- 检查对象怪兽是否有效并破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		and rc:IsRelateToEffect(e) and rc:IsFaceup() then
		-- 对对方造成伤害，伤害值为超量怪兽阶级×300
		Duel.Damage(1-tp,rc:GetRank()*300,REASON_EFFECT)
	end
end
