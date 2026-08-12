--ジェネレーション・ネクスト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己基本分比对方少的场合才能发动。从自己的卡组·墓地选持有双方基本分差的数值以下的攻击力的「元素英雄」怪兽、「栗子球」怪兽、「新空间侠」怪兽之内任意1只加入手卡或特殊召唤。这个回合，自己不能作那张卡以及那些同名卡的效果的发动。
function c85787173.initial_effect(c)
	-- ①：自己基本分比对方少的场合才能发动。从自己的卡组·墓地选持有双方基本分差的数值以下的攻击力的「元素英雄」怪兽、「栗子球」怪兽、「新空间侠」怪兽之内任意1只加入手卡或特殊召唤。这个回合，自己不能作那张卡以及那些同名卡的效果的发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,85787173+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c85787173.condition)
	e1:SetTarget(c85787173.target)
	e1:SetOperation(c85787173.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c85787173.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己基本分是否比对方少
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 过滤函数：筛选卡组或墓地中攻击力在双方基本分差以下且满足加入手卡或特殊召唤条件的「元素英雄」、「栗子球」、「新空间侠」怪兽
function c85787173.thfilter(c,e,tp,ft,atk)
	return c:IsSetCard(0x3008,0xa4,0x1f) and c:IsAttackBelow(atk) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 定义发动目标与操作信息函数
function c85787173.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上的怪兽区域空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 计算双方基本分的差值
	local atk=math.abs(Duel.GetLP(0)-Duel.GetLP(1))
	-- 在发动时检查卡组或墓地是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85787173.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,ft,atk) end
	-- 设置操作信息：从卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 设置操作信息：从卡组或墓地将1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义效果处理函数
function c85787173.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的怪兽区域空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 计算双方基本分的差值
	local atk=math.abs(Duel.GetLP(0)-Duel.GetLP(1))
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组或墓地选择1只符合条件的怪兽（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c85787173.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,ft,atk)
	local tc=g:GetFirst()
	if tc then
		local res=nil
		if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断是否只能特殊召唤，或者在加入手卡和特殊召唤中选择了特殊召唤
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选中的怪兽在自己场上表侧表示特殊召唤
			res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选中的怪兽加入手卡
			res=Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		end
		if res~=0 then
			-- 这个回合，自己不能作那张卡以及那些同名卡的效果的发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(c85787173.aclimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 给玩家注册该回合内不能发动该卡及同名卡效果的限制
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 定义限制发动效果的卡名判定函数
function c85787173.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
