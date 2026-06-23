--テンプレート・スキッパー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往作为电子界族连接怪兽所连接区的自己场上特殊召唤。
-- ②：自己主要阶段才能发动。从自己的手卡·墓地把1只电子界族怪兽除外。这个回合连接召唤的场合，这张卡可以作为这个效果除外的怪兽的同名卡来成为连接素材。
local s,id,o=GetID()
-- 创建两个效果，分别对应①特殊召唤和②除外效果
function s.initial_effect(c)
	-- ①：这张卡可以从手卡往作为电子界族连接怪兽所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetValue(s.spval)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己的手卡·墓地把1只电子界族怪兽除外。这个回合连接召唤的场合，这张卡可以作为这个效果除外的怪兽的同名卡来成为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上存在的电子界族连接怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK)
end
-- 检查场上所有电子界族连接怪兽的连接区域，合并为一个zone值
function s.checkzone(tp)
	local zone=0
	-- 获取场上所有电子界族连接怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历该卡片组中的每张怪兽卡
	for tc in aux.Next(g) do
		zone=zone|tc:GetLinkedZone(tp)
	end
	return zone&0x1f
end
-- 判断特殊召唤条件是否满足，即是否有足够的怪兽区域
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=s.checkzone(tp)
	-- 判断目标玩家在指定区域是否有足够的空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 设置特殊召唤时的连接区域值
function s.spval(e,c)
	local tp=c:GetControler()
	local zone=s.checkzone(tp)
	return 0,zone
end
-- 过滤条件：电子界族且可除外的怪兽
function s.rmfilter(c,tc)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToRemove()
end
-- 设置除外效果的发动条件和目标
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即手牌或墓地是否存在电子界族可除外怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 设置除外效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 除外效果的处理函数
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张手牌或墓地的电子界族怪兽进行除外
	local cg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,aux.ExceptThisCard(e))
	if cg:GetCount()==0 then return end
	local code1,code2=cg:GetFirst():GetOriginalCodeRule()
	-- 执行除外操作并确认是否成功除外
	if Duel.Remove(cg,POS_FACEUP,REASON_EFFECT)~=0 and cg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED)
		and c:IsRelateToEffect(e) and c:IsFaceup() and c:IsType(TYPE_MONSTER) then
		-- 为该卡添加一个连接码，使其可作为连接素材使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_LINK_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(code1)
		c:RegisterEffect(e1)
		if code2 then
			local e2=e1:Clone()
			e2:SetValue(code2)
			c:RegisterEffect(e2)
		end
	end
end
