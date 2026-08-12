--コクーン・ヴェール
-- 效果：
-- 把自己场上表侧表示存在的1只名字带有「茧状体」的怪兽作为祭品才能发动。这个回合效果的对玩家的伤害变成0。之后，作为祭品的名字带有「茧状体」的怪兽记述的1只名字带有「新空间侠」的怪兽从手卡·卡组·墓地特殊召唤。
function c56641453.initial_effect(c)
	-- 把自己场上表侧表示存在的1只名字带有「茧状体」的怪兽作为祭品才能发动。这个回合效果的对玩家的伤害变成0。之后，作为祭品的名字带有「茧状体」的怪兽记述的1只名字带有「新空间侠」的怪兽从手卡·卡组·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c56641453.cost)
	e1:SetTarget(c56641453.target)
	e1:SetOperation(c56641453.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己场上表侧表示的「茧状体」怪兽，且其记述的「新空间侠」怪兽存在于手卡、卡组或墓地
function c56641453.filter1(c,e,tp)
	-- 检查卡片是否为表侧表示的「茧状体」怪兽，且手卡、卡组、墓地存在至少1张其记述的「新空间侠」怪兽
	return c:IsFaceup() and c:IsSetCard(0x1e) and Duel.IsExistingMatchingCard(c56641453.filter2,tp,0x13,0,1,nil,c,e,tp)
end
-- 过滤函数：筛选属于「新空间侠」系列、被解放的怪兽所记述、且可以特殊召唤的怪兽
function c56641453.filter2(c,mc,e,tp)
	-- 检查卡片是否为「新空间侠」怪兽，其卡名被解放的怪兽所记述，且可以被特殊召唤
	return c:IsSetCard(0x1f) and aux.IsCodeListed(mc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 发动代价：将Label设为1以标记需要进行解放检测，并返回true
function c56641453.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果发动时的目标选择与代价支付处理
function c56641453.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==1
		e:SetLabel(0)
		-- 检查是否满足发动代价的标记，且自己场上的怪兽区域有空位
		return res and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
			-- 检查自己场上是否存在至少1只满足解放过滤条件的可解放怪兽
			and Duel.CheckReleaseGroup(tp,c56641453.filter1,1,nil,e,tp) end
	e:SetLabel(0)
	-- 玩家选择1只满足解放过滤条件的可解放怪兽
	local rg=Duel.SelectReleaseGroup(tp,c56641453.filter1,1,1,nil,e,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(rg,REASON_COST)
	-- 将被解放的怪兽设为当前连锁的处理对象，以便后续效果确认其卡名
	Duel.SetTargetCard(rg)
	-- 设置特殊召唤的操作信息，指定从手卡、卡组、墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 效果处理函数：使本回合的效果伤害变成0，并特殊召唤对应的「新空间侠」怪兽
function c56641453.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合效果的对玩家的伤害变成0。之后，作为祭品的名字带有「茧状体」的怪兽记述的1只名字带有「新空间侠」的怪兽从手卡·卡组·墓地特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c56641453.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册“效果伤害变成0”的全局效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册“免受效果伤害”的全局状态标记效果
	Duel.RegisterEffect(e2,tp)
	-- 检查自己场上是否有空余的怪兽区域，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为发动代价被解放的怪兽
	local tc=Duel.GetFirstTarget()
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡、卡组、墓地中选择1只满足过滤条件且不受王家长眠之谷影响的「新空间侠」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c56641453.filter2),tp,0x13,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 伤害计算过滤函数：如果是效果伤害则将其变为0，否则保持原数值
function c56641453.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
