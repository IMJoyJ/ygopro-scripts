--Witness of the Ancient
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- 自己场上或墓地有同调怪兽存在的场合：可以从手牌把此卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 此卡特殊召唤成功的场合可以发动。从额外卡组·墓地最多3种同调怪兽当作永续魔法卡在自己的魔法与陷阱区域表侧表示放置。那之后，把1只等级等于放置数量的衍生物（机械族·光属性·攻0/守0）在自己场上特殊召唤。这个效果的发动后，直到回合结束时自己从额外卡组只能特殊召唤同调怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤场上及墓地的表侧表示同调怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 自身特招效果的发动条件判断
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上或墓地是否存在同调怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- 自身特招效果的目标与分类设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 自身特招效果的处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤可当作永续魔法表侧放置的同调怪兽
function s.placefilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 放置同调怪兽及特招衍生物效果的目标与分类设置
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local res=false
	-- 获取额外卡组及墓地符合条件的同调怪兽
	local g=Duel.GetMatchingGroup(s.placefilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,tp)
	local ct=g:GetClassCount(Card.GetCode)
	-- 限制最多放置数量不超过魔陷区空位数
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<ct then ct=Duel.GetLocationCount(tp,LOCATION_SZONE) end
	if ct>3 then ct=3 end
	for i=1,ct do
		-- 检查玩家是否可以特殊召唤对应等级的衍生物
		if Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,i,RACE_MACHINE,ATTRIBUTE_LIGHT) then
			res=true
			break
		end
	end
	-- 检查魔陷区是否有空余格子
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查怪兽区是否有空余格子特招衍生物
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and res end
	-- 设置连锁操作信息：生成衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 检查选择的怪兽组卡名互不相同且可特招对应等级的衍生物
function s.gcheck(g,tp)
	-- 判断卡名互不相同且满足衍生物特招条件
	return aux.dncheck(g) and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,g:GetCount(),RACE_MACHINE,ATTRIBUTE_LIGHT)
end
-- 放置同调怪兽及召唤衍生物的效果处理
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认魔陷区存在可用格子
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 获取魔陷区可用格子数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if ft>3 then ft=3 end
		-- 获取不受王家谷影响的额外卡组及墓地同调怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.placefilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,tp)
		if g:GetCount()>0 then
			-- 提示选择要放置到场上的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			local sg=g:SelectSubGroup(tp,s.gcheck,false,1,ft,tp)
			-- 遍历所选的同调怪兽
			for tc in aux.Next(sg) do
				-- 将选择的同调怪兽移到魔陷区表侧表示放置
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				-- 当作永续魔法卡使用
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				tc:RegisterEffect(e1)
			end
			-- 检查怪兽区是否有空余格子
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 检查是否可以特招对应等级的衍生物
				and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,sg:GetCount(),RACE_MACHINE,ATTRIBUTE_LIGHT) then
				-- 生成衍生物卡片对象
				local token=Duel.CreateToken(tp,id+o)
				-- 把1只等级等于放置数量的衍生物（机械族·光属性·攻0/守0）在自己场上特殊召唤
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				e1:SetValue(sg:GetCount())
				token:RegisterEffect(e1,true)
				-- 表侧表示特殊召唤衍生物
				Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己从额外卡组只能特殊召唤同调怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 对玩家注册自锁效果
	Duel.RegisterEffect(e1,tp)
end
-- 额外卡组特殊召唤限制过滤（只能特招同调怪兽）
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
