--御巫かみかくし
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽给自己场上1只「御巫」怪兽当作装备魔法卡使用来装备。场上有仪式怪兽卡存在的场合，可以再给与对方为自己场上的装备魔法卡数量×500伤害。
-- ②：把墓地的这张卡除外才能发动。自己的手卡·除外状态的1只「御巫」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册两个效果，第一个为发动效果，第二个为墓地发动效果
function s.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽给自己场上1只「御巫」怪兽当作装备魔法卡使用来装备。场上有仪式怪兽卡存在的场合，可以再给与对方为自己场上的装备魔法卡数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己的手卡·除外状态的1只「御巫」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 将此卡从游戏中除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选对方场上的表侧表示且能改变控制权的怪兽
function s.filter(c,tp)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 过滤函数，用于筛选自己场上的表侧表示的「御巫」怪兽
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18d)
end
-- 效果处理时点，判断是否满足发动条件并选择对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp) end
	if chk==0 then
		-- 获取玩家当前魔法陷阱区域可用空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
		-- 判断是否有至少1只对方场上的表侧表示怪兽可以作为对象
		return ft>0 and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp)
			-- 判断自己场上是否存在至少1只「御巫」怪兽
			and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一个对方场上的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
end
-- 过滤函数，用于筛选场上存在的仪式怪兽
function s.dafilter(c)
	return c:IsFaceup() and bit.band(c:GetOriginalType(),0x81)==0x81
end
-- 过滤函数，用于筛选装备魔法卡
function s.dafilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end
-- 发动效果时处理装备和伤害判定
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然在场且自己魔法陷阱区有空位
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的「御巫」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从自己场上选择一只「御巫」怪兽进行装备
		local sc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		-- 执行装备操作，若成功则设置装备限制效果
		if sc and Duel.Equip(tp,tc,sc) then
			-- 设置装备限制效果，确保只能装备给特定怪兽
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(sc)
			e1:SetValue(s.eqlimit)
			tc:RegisterEffect(e1)
			-- 判断场上有无仪式怪兽存在
			if Duel.IsExistingMatchingCard(s.dafilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
				-- 判断自己魔法陷阱区是否有装备魔法卡
				and Duel.IsExistingMatchingCard(s.dafilter2,tp,LOCATION_SZONE,0,1,nil)
				-- 询问玩家是否发动伤害效果
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否给与对方伤害？"
				-- 中断当前效果处理流程，使后续处理视为错时点
				Duel.BreakEffect()
				-- 计算装备魔法卡数量乘以500作为伤害值
				local d=Duel.GetMatchingGroupCount(s.dafilter2,tp,LOCATION_SZONE,0,nil)*500
				-- 对对方造成相应伤害
				Duel.Damage(1-tp,d,REASON_EFFECT)
			end
		end
	end
end
-- 装备限制函数，确保只能装备给指定怪兽
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- 过滤函数，用于筛选可特殊召唤的「御巫」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsFaceupEx()
end
-- 特殊召唤效果处理时点，判断是否满足发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己魔法区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或除外状态是否存在至少1只「御巫」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息，告知连锁中将要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
-- 执行特殊召唤效果处理流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己魔法区域是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或除外状态选择一只「御巫」怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()<=0 then return end
	-- 将所选怪兽特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
