--No.97 龍影神ドラッグラビオン
-- 效果：
-- 8星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能把场上的这张卡作为效果的对象。
-- ②：把这张卡1个超量素材取除才能发动。从自己的额外卡组·墓地选「No.97 龙影神 引力子龙」以外的龙族「No.」怪兽2种类。那之内的1只特殊召唤，另1只作为那超量素材。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤，不用由这个效果特殊召唤的怪兽不能攻击宣言。
function c28400508.initial_effect(c)
	-- 为卡片添加等级为8、需要2只怪兽进行超量召唤的手续
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- 对方不能把场上的这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	-- 设置该效果为使此卡不会成为对方效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除才能发动。从自己的额外卡组·墓地选「No.97 龙影神 引力子龙」以外的龙族「No.」怪兽2种类。那之内的1只特殊召唤，另1只作为那超量素材。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤，不用由这个效果特殊召唤的怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28400508,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,28400508)
	e2:SetCost(c28400508.spcost)
	e2:SetTarget(c28400508.sptg)
	e2:SetOperation(c28400508.spop)
	c:RegisterEffect(e2)
end
-- 设置该卡为No.97系列的超量怪兽
aux.xyz_number[28400508]=97
-- 支付1个超量素材作为发动代价
function c28400508.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：检查是否为龙族、No.系列、非本卡、可作为叠放卡且不与目标卡同名
function c28400508.cfilter(c,tc)
	return c:IsRace(RACE_DRAGON) and c:IsSetCard(0x48) and not c:IsCode(28400508)
		and c:IsCanOverlay() and not c:IsCode(tc:GetCode())
end
-- 过滤函数：检查是否为龙族、No.系列、非本卡、超量怪兽、可特殊召唤、满足场地召唤条件、且存在满足叠放条件的卡
function c28400508.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsSetCard(0x48) and not c:IsCode(28400508)
		and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查该卡是否在额外卡组且有足够召唤空位
		and (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
			-- 检查该卡是否在墓地且有足够召唤空位
			or c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		-- 检查是否存在满足叠放条件的卡
		and Duel.IsExistingMatchingCard(c28400508.cfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,c,c)
end
-- 设置发动时的处理条件：确认场上存在满足条件的卡
function c28400508.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 设置发动时的处理条件：确认场上存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c28400508.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 发动效果时的处理：选择1只满足条件的怪兽特殊召唤，并选择1只作为叠放素材
function c28400508.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28400508.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local fid=0
	if tc then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 选择满足条件的卡作为超量素材
		local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28400508.cfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,tc,tc)
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 将选中的卡作为叠放素材叠放
		Duel.Overlay(tc,g2)
		fid=tc:GetFieldID()
	end
	-- 设置永续效果：发动后直到回合结束时自己不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
	-- 设置永续效果：发动后直到回合结束时自己场上的非特殊召唤的怪兽不能攻击宣言
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c28400508.ftarget)
	e2:SetLabel(fid)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能攻击宣言的效果
	Duel.RegisterEffect(e2,tp)
end
-- 设置攻击宣言限制的过滤函数：判断是否为特殊召唤的怪兽
function c28400508.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
