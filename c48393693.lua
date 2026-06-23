--ガガガガール－ゼロゼロコール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方从额外卡组把怪兽特殊召唤的场合，以自己场上1只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤。那之后，只用这张卡和作为对象的怪兽为素材进行超量召唤。那个时候，这张卡的等级当作和作为对象的怪兽相同等级使用。
-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。对方场上1只表侧表示怪兽的攻击力变成0。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- ①：对方从额外卡组把怪兽特殊召唤的场合，以自己场上1只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤。那之后，只用这张卡和作为对象的怪兽为素材进行超量召唤。那个时候，这张卡的等级当作和作为对象的怪兽相同等级使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。对方场上1只表侧表示怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力变成0"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_MOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 过滤对方从额外卡组特殊召唤的怪兽
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 触发条件：对方从额外卡组把怪兽特殊召唤的场合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 创建临时等级改变效果
function s.CreateTempLevelEffect(ec,level_source)
	-- 那个时候，这张卡的等级当作和作为对象的怪兽相同等级使用。
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetValue(s.xyzlv)
	e1:SetLabel(level_source:GetLevel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	ec:RegisterEffect(e1,true)
	return e1
end
-- 在执行回调期间临时设置怪兽等级并在执行后重置
function s.SetTempLevel(ec,level_source,callback)
	local e1=s.CreateTempLevelEffect(ec,level_source)
	local res,resetflag = callback()
	if resetflag and e1 then e1:Reset() end
	return res
end
-- 设定超量召唤时的等级为目标怪兽的等级
function s.xyzlv(e,c,rc)
	return e:GetHandler():GetLevel() | (e:GetLabel() << 16)
end
-- 过滤场上可作为超量素材的表侧表示怪兽并检测能否进行超量召唤
function s.xyzfilter(c,tp,mc)
	if not c:IsFaceup() or not c:IsLevelAbove(1) then return false end
	local mg=Group.FromCards(c,mc)
	return s.SetTempLevel(mc,c,function()
		-- 检测额外卡组是否存在可以只用这2只怪兽作为素材超量召唤的怪兽
		return Duel.IsExistingMatchingCard(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,1,nil,mg,2,2),true
	end)
end
-- 特殊召唤与超量召唤效果的发动检测与操作整理
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xyzfilter(chkc,tp,c) end
	-- 检测玩家是否能特殊召唤2次
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 且自己怪兽区域有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且场上存在可作为超量素材的目标怪兽
		and Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp,c) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示怪兽作为超量素材对象
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	-- 设置特殊召唤自身与超量怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_EXTRA)
end
-- 特殊召唤并超量召唤效果的具体处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若特殊召唤自身失败则不处理后续效果
	if not c:IsRelateToChain() or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 获取当前效果作为超量素材的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or tc:IsFacedown() or not tc:IsControler(tp) then return end
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	s.SetTempLevel(c,tc,function()
		-- 刷新场地信息
		Duel.AdjustAll()
		-- 获取可以用这2只怪兽作为素材超量召唤的怪兽组
		local xyzg=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,nil,mg,2,2)
		if xyzg:GetCount()>0 then
			-- 提示玩家选择要超量召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
			-- 以这2只怪兽为素材进行超量召唤
			Duel.XyzSummon(tp,xyz,mg)
			return nil, false
		end
		return nil, true
	end)
end
-- 触发条件：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 降低攻击力效果的发动检测与操作整理
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上攻击力不为0的表侧表示怪兽
	local g=Duel.GetMatchingGroup(aux.nzatk,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置降低怪兽攻击力的操作信息
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
-- 降低攻击力效果的具体处理
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择对方场上1只表侧表示攻击力不为0的怪兽
	local g=Duel.GetMatchingGroup(aux.nzatk,tp,0,LOCATION_MZONE,nil):Select(tp,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 对选中的怪兽显示选择动画
		Duel.HintSelection(g)
		-- 对方场上1只表侧表示怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
