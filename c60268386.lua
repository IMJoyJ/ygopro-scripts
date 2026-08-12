--紋章獣グリフォン
--not fully implemented
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把「纹章兽 狮鹫」以外的1只「纹章兽」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤。
-- ②：以怪兽3只以上为素材的「No.」超量怪兽超量召唤的场合，这张卡可以作为2只数量的超量素材。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特殊召唤效果（e1）和作为2只超量素材效果（e2）
function s.initial_effect(c)
	-- ①：从卡组把「纹章兽 狮鹫」以外的1只「纹章兽」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以怪兽3只以上为素材的「No.」超量怪兽超量召唤的场合，这张卡可以作为2只数量的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.sxyzfilter)
	e2:SetValue(id)
	e2:SetCountLimit(1,id+o)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「纹章兽 狮鹫」以外的「纹章兽」怪兽
function s.costfilter(c)
	return c:IsSetCard(0x76) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤效果的发动代价：从卡组将1只「纹章兽 狮鹫」以外的「纹章兽」怪兽送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「纹章兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1张满足条件的「纹章兽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 特殊召唤效果的发动条件与目标确认：检查怪兽区域是否有空位，且自身是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理：特殊召唤自身，并适用后续的额外卡组特殊召唤限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤。（限制非超量召唤的部分）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家不能从额外卡组进行超量召唤以外的特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
	-- 这个效果的发动后，直到回合结束时自己若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤。（限制超量素材的部分）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(0x7f,0x7f)
	e2:SetTarget(s.tlmtg)
	e2:SetValue(s.tlmval)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家不能使用原本卡名不含「纹章兽」或「No.」的怪兽作为超量素材的效果
	Duel.RegisterEffect(e2,tp)
	-- 这个效果的发动后，直到回合结束时自己若非以只用原本卡名包含「纹章兽」或「No.」的怪兽为素材的超量召唤则不能从额外卡组把怪兽特殊召唤。（限制超量召唤素材的辅助判定）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(67120578)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册用于配合超量素材限制的系统内部标记效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制玩家不能从额外卡组特殊召唤超量怪兽以外的怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and bit.band(sumtype,SUMMON_TYPE_XYZ)~=SUMMON_TYPE_XYZ
end
-- 过滤原本卡名不包含「纹章兽」或「No.」的怪兽
function s.tlmtg(e,c)
	return not c:IsOriginalSetCard(0x76,0x48)
end
-- 限制自己场上的上述怪兽不能作为超量素材
function s.tlmval(e,c)
	if not c then return false end
	return c:GetControler()==e:GetOwnerPlayer()
end
-- 过滤「No.」超量怪兽，用于作为2只超量素材的效果
function s.sxyzfilter(e,c)
	return c:IsSetCard(0x48)
end
