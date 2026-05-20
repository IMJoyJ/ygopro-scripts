--リザレクション・ブレス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「勇者衍生物」存在的场合才能发动。从自己的手卡·墓地选最多2只怪兽特殊召唤（同名卡最多1张）。那之后，可以从自己的手卡·墓地选有「勇者衍生物」的衍生物名记述的1张装备魔法卡给自己场上1只可以装备的怪兽装备。这个效果特殊召唤的怪兽从场上离开的场合除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function c64018647.initial_effect(c)
	-- 注册卡片效果中记述了「勇者衍生物」（卡密码：3285552）的卡片关联信息
	aux.AddCodeList(c,3285552)
	-- ①：自己场上有「勇者衍生物」存在的场合才能发动。从自己的手卡·墓地选最多2只怪兽特殊召唤（同名卡最多1张）。那之后，可以从自己的手卡·墓地选有「勇者衍生物」的衍生物名记述的1张装备魔法卡给自己场上1只可以装备的怪兽装备。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,64018647+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c64018647.condition)
	e1:SetTarget(c64018647.target)
	e1:SetOperation(c64018647.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「勇者衍生物」
function c64018647.cfilter(c)
	return c:IsFaceup() and c:IsCode(3285552)
end
-- 发动条件：自己场上有「勇者衍生物」存在
function c64018647.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「勇者衍生物」
	return Duel.IsExistingMatchingCard(c64018647.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果发动时的目标选择与合法性检测函数
function c64018647.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或墓地是否存在至少1只可以特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：从手卡或墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤条件：场上表侧表示且可以装备指定装备卡的对象怪兽
function c64018647.CanEquipFilter(c,eqc)
	return c:IsFaceup() and eqc:CheckEquipTarget(c)
end
-- 过滤条件：手卡或墓地中记述了「勇者衍生物」且场上有合法装备对象的装备魔法卡
function c64018647.eqfilter(c,tp)
	-- 检查卡片是否记述了「勇者衍生物」、是否为装备魔法卡、在场上是否唯一存在且未被禁止使用
	return aux.IsCodeListed(c,3285552) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 检查自己场上是否存在可以装备该装备卡的合法怪兽
		and Duel.IsExistingMatchingCard(c64018647.CanEquipFilter,tp,LOCATION_MZONE,0,1,nil,c)
end
-- 效果处理的执行函数
function c64018647.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算自己场上可用于特殊召唤的怪兽区域空格数，最多为2个
	local ft=math.min(2,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取手卡或墓地中所有可以特殊召唤的怪兽（受王家长眠之谷影响）
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,0,tp,false,false)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1到ft张卡名不同的怪兽
	local g1=tg:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	if not g1 then return end
	-- 遍历玩家选择的怪兽集合
	for tc in aux.Next(g1) do
		-- 尝试将怪兽以表侧表示特殊召唤到场上
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽从场上离开的场合除外。那之后，可以从自己的手卡·墓地选有「勇者衍生物」的衍生物名记述的1张装备魔法卡给自己场上1只可以装备的怪兽装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(LOCATION_REMOVED)
			tc:RegisterEffect(e1,true)
		end
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
	-- 检查自己场上是否有可用的魔法与陷阱区域空格
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手卡或墓地是否存在满足条件的装备魔法卡
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp)
		-- 询问玩家是否选择装备魔法卡进行装备
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否选装备魔法卡装备？"
		-- 中断当前效果处理，使后续的装备处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要装备的装备魔法卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 让玩家从手卡或墓地选择1张满足条件的装备魔法卡
		local eqg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp)
		local eqc=eqg:GetFirst()
		-- 提示玩家选择要装备的表侧表示怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家选择1只可以装备该装备魔法卡的怪兽
		local mg=Duel.SelectMatchingCard(tp,s.CanEquipFilter,tp,LOCATION_MZONE,0,1,1,nil,eqc)
		-- 将选中的装备魔法卡装备给选中的怪兽
		Duel.Equip(tp,eqc,mg:GetFirst())
	end
end
