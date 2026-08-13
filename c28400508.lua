--No.97 龍影神ドラッグラビオン
-- 效果：
-- 8星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能把场上的这张卡作为效果的对象。
-- ②：把这张卡1个超量素材取除才能发动。从自己的额外卡组·墓地选「No.97 龙影神 引力子龙」以外的龙族「No.」怪兽2种类。那之内的1只特殊召唤，另1只作为那超量素材。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤，不用由这个效果特殊召唤的怪兽不能攻击宣言。
function c28400508.initial_effect(c)
	-- 为这张卡赋予XYZ召唤手续：用2只等级8的怪兽叠放进行XYZ召唤（对应召唤条件“8星怪兽×2”）。
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：对方不能把场上的这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	-- 将e1的值函数设为aux.tgoval，使该效果在判定时只让对方的效果无法以这张卡为对象，实现“对方不能把场上的这张卡作为效果的对象”这一免疫效果。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把这张卡1个超量素材取除才能发动。从自己的额外卡组·墓地选「No.97 龙影神 引力子龙」以外的龙族「No.」怪兽2种类。那之内的1只特殊召唤，另1只作为那超量素材。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤，不用由这个效果特殊召唤的怪兽不能攻击宣言。
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
-- 将这张卡在“No.”系列的编号记录为97，使其他涉及“No.”卡的处理能够识别这张卡为No.97。
aux.xyz_number[28400508]=97
-- 效果发动的代价函数：在cost检查阶段确认这张卡可移除1个超量素材，实际发动时移除1个超量素材作为代价（对应“把这张卡1个超量素材取除才能发动”）。
function c28400508.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义超量素材候选的过滤条件：须为龙族、卡名含“No.”、不是No.97本身、可作为超量素材，并且与已选定的特殊召唤对象卡名不同，确保选出的是不同种类的另一只。注意用于“另1只作为那超量素材”的选择。
function c28400508.cfilter(c,tc)
	return c:IsRace(RACE_DRAGON) and c:IsSetCard(0x48) and not c:IsCode(28400508)
		and c:IsCanOverlay() and not c:IsCode(tc:GetCode())
end
-- 定义特殊召唤候选怪兽的过滤条件：须为龙族、卡名含“No.”、不是No.97、是XYZ怪兽、满足苏生限制且能被特殊召唤；并根据它所在的位置保证有对应空格（额外卡组需额外怪兽区空格，墓地需主怪兽区空格）；同时场上/额外/墓地还存在着另一只可作为其素材的龙族No.怪兽。
function c28400508.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsSetCard(0x48) and not c:IsCode(28400508)
		and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 子条件：若候选怪兽在额外卡组，则要求自己场上有可供额外卡组怪兽特殊召唤的空位（通过Duel.GetLocationCountFromEx判断）。
		and (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
			-- 子条件：若候选怪兽在墓地，则要求自己的主要怪兽区域有空位可供特殊召唤。
			or c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		-- 同时要求自己的额外卡组·墓地中存在另一只满足cfilter条件的龙族No.怪兽，且该怪兽不是当前候选卡本身（用ex排除），以保证能选出超量素材。
		and Duel.IsExistingMatchingCard(c28400508.cfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,c,c)
end
-- ②效果的发动目标判定函数：检查发动时是否存在符合条件的特殊召唤候选，并设置操作信息；满足条件才能发动该效果。
function c28400508.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在Check阶段（chk==0）确认自己额外卡组·墓地存在至少1只满足spfilter的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28400508.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：本效果将进行1次从额外卡组·墓地的特殊召唤，便于其他卡（如星尘龙等）进行对应连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 效果处理函数：先选择要特殊召唤的龙族No.怪兽并选择另一只作为超量素材；将前者特殊召唤，把后者叠放在其下方作为超量素材；随后给自己附加直到回合结束的“不能特殊召唤怪兽”和“非本次效果特殊召唤的怪兽不能攻击宣言”自肃。
function c28400508.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示“请选择要特殊召唤的卡”，便于玩家从候选中选定要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己额外卡组·墓地选择1只满足spfilter的龙族No.怪兽作为特殊召唤对象（应用王家长眠之谷过滤，处理墓地/额外相关限制）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28400508.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local fid=0
	if tc then
		-- 显示选择提示“请选择要作为超量素材的卡”，便于玩家选择要叠放为超量素材的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从自己额外卡组·墓地选择1只满足cfilter的龙族No.怪兽作为超量素材，排除已选的特殊召唤对象，确保两张卡种类不同（应用王家长眠之谷过滤）。
		local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28400508.cfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,tc,tc)
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上（进行正规特殊召唤，检查召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 将第二只选择的怪兽叠放到已特殊召唤的怪兽下方，使其成为该怪兽的超量素材。
		Duel.Overlay(tc,g2)
		fid=tc:GetFieldID()
	end
	-- 这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤，不用由这个效果特殊召唤的怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能把怪兽特殊召唤”的限制效果注册为场上持续效果，对这张卡的控制者生效，直到结束阶段。
	Duel.RegisterEffect(e1,tp)
	-- 不用由这个效果特殊召唤的怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c28400508.ftarget)
	e2:SetLabel(fid)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能攻击宣言”的限制效果注册到场上，使效果适用于己方场上所有非本次特殊召唤的怪兽，直到结束阶段。
	Duel.RegisterEffect(e2,tp)
end
-- 攻击限制的过滤条件：若场上怪兽的FieldID与本次特殊召唤的怪兽不同，则不能进行攻击宣言；即只有本次效果特殊召唤的怪兽可以攻击。
function c28400508.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
