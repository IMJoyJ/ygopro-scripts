--NEXT
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己场上没有卡存在的场合，这张卡的发动从手卡也能用。
-- ①：从自己的手卡·墓地选「新空间侠」怪兽以及「元素英雄 新宇侠」任意数量守备表示特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽的效果无效化。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是融合怪兽不能从额外卡组特殊召唤。
function c74414885.initial_effect(c)
	-- 注册卡片记有「元素英雄 新宇侠」的卡片密码
	aux.AddCodeList(c,89943723)
	-- 注册卡片记有「元素英雄」系列怪兽的事实
	aux.AddSetNameMonsterList(c,0x3008)
	-- ①：从自己的手卡·墓地选「新空间侠」怪兽以及「元素英雄 新宇侠」任意数量守备表示特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽的效果无效化。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,74414885+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c74414885.target)
	e1:SetOperation(c74414885.activate)
	c:RegisterEffect(e1)
	-- 自己场上没有卡存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74414885,1))  --"适用「新空间扩界」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c74414885.handcon)
	c:RegisterEffect(e2)
end
-- 过滤手卡·墓地中可以守备表示特殊召唤的「新空间侠」怪兽或「元素英雄 新宇侠」
function c74414885.filter(c,e,tp)
	return (c:IsCode(89943723) or c:IsSetCard(0x1f)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的靶向与可行性检测
function c74414885.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在至少1张满足特殊召唤条件的卡
		and Duel.IsExistingMatchingCard(c74414885.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从手卡·墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理的执行函数，处理特殊召唤及后续限制效果
function c74414885.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取手卡·墓地中满足特殊召唤条件且不受「王家之谷」影响的卡片组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c74414885.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的卡中选择1到ft张卡名不同的卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 遍历选中的卡片组
	for tc in aux.Next(sg) do
		-- 将选中的怪兽以表侧守备表示逐步特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是融合怪兽不能从额外卡组特殊召唤。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetRange(LOCATION_MZONE)
		e3:SetAbsoluteRange(tp,1,0)
		e3:SetTarget(c74414885.splimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
-- 限制不能从额外卡组特殊召唤融合怪兽以外的怪兽
function c74414885.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 手卡发动的条件函数：自己场上没有卡存在
function c74414885.handcon(e)
	-- 判断自己场上的卡数量是否为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end
