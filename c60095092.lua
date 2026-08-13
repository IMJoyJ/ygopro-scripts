--VV－ソロアクティベート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组选1只「群豪」灵摆怪兽在自己的灵摆区域放置。
-- ②：场地区域有卡存在的场合，把墓地的这张卡除外，以自己的主要怪兽区域1只「群豪」怪兽为对象才能发动。那只自己怪兽的位置向那个相邻的怪兽区域移动。
local s,id,o=GetID()
-- 定义该卡的效果注册函数：注册①从卡组将「群豪」灵摆怪兽放置到灵摆区的效果，以及②除外墓地的自身并将场上「群豪」怪兽向相邻区域移动的效果。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从卡组选1只「群豪」灵摆怪兽在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"在灵摆区域放置"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetValue(s.zones)
	c:RegisterEffect(e1)
	-- ②：场地区域有卡存在的场合，把墓地的这张卡除外，以自己的主要怪兽区域1只「群豪」怪兽为对象才能发动。那只自己怪兽的位置向那个相邻的怪兽区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"位置移动"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.seqcon)
	-- 将②效果的发动代价设置为把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.seqtg)
	e2:SetOperation(s.seqop)
	c:RegisterEffect(e2)
end
-- 计算这张卡发动时可以放置的灵摆区域位掩码：若我方灵摆区左/右任一位置空置则开放对应位置，若两个都空或非发动场合则返回全部区域，用于限制魔法卡发动时的摆放位置。
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	-- 检查我方灵摆区左侧（0号位）是否为空。
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	-- 检查我方灵摆区右侧（1号位）是否为空。
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	if not b or p0 and p1 then return zone end
	if p0 then zone=zone-0x1 end
	if p1 then zone=zone-0x10 end
	return zone
end
-- 定义检索卡组的过滤器：卡片为「群豪」灵摆怪兽且不是禁止卡。
function s.penfilter(c)
	return c:IsSetCard(0x17d) and c:IsType(TYPE_PENDULUM)
		and not c:IsForbidden()
end
-- ①效果的发动条件/选卡部分：灵摆区域有空位且卡组中存在符合条件的「群豪」灵摆怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 进行发动合法性检查：我方灵摆区的左或右至少有一个空位。
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 并且我方卡组中存在至少1张满足s.penfilter的「群豪」灵摆怪兽。
		and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果处理：若灵摆区仍有空位，从卡组选择1只「群豪」灵摆怪兽正面放置到自己的灵摆区域。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若我方两个灵摆区域都被占据，则本效果不处理。
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 向操作玩家发送“请选择要放置到场上的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从我方卡组中筛选并选择1张满足s.penfilter条件的「群豪」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的灵摆怪兽以表侧表示移动到玩家自己的灵摆区域。
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- ②效果的发动条件判定：场地区域存在至少1张卡。
function s.seqcon(e)
	-- 检查双方场地区域（FZONE）合计是否存在至少1张卡。
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 定义②效果可选择的怪兽条件：我方主要怪兽区域表侧表示的「群豪」怪兽，且其左右相邻的某个主要怪兽区域为空位。
function s.seqfilter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 or not c:IsSetCard(0x17d) or not c:IsFaceup() then return false end
	-- 若该怪兽不在最左列且左侧相邻区域为空，则满足可移动条件。
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 若该怪兽不在最右列且右侧相邻区域为空，则同样满足可移动条件。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- ②效果的目标选择步骤：以我方主要怪兽区域1只满足移动条件的「群豪」表侧怪兽为对象。
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.seqfilter(chkc) end
	-- 发动合法性检查：我方主要怪兽区存在至少1只可移动且能成为对象的「群豪」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.seqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家发送“请选择效果的对象”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 将选择的那只怪兽登记为效果对象。
	Duel.SelectTarget(tp,s.seqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：取得对象怪兽后，在可选相邻区域中选择一个位置并移动该怪兽。
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local seq=tc:GetSequence()
	if seq>4 then return end
	local flag=0
	-- 若对象左侧有相邻区域且为空位，将左侧格加入可选移动区域位掩码。
	if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	-- 若对象右侧有相邻区域且为空位，将右侧格加入可选移动区域位掩码。
	if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	if flag==0 then return end
	-- 向操作玩家发送“请选择要移动到的位置”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家从可选的相邻主要怪兽区域中选择1个移动目的地，返回对应区域位掩码。
	local zone=Duel.SelectField(tp,1,LOCATION_MZONE,0,~flag)
	local nseq=math.log(zone,2)
	-- 将对象怪兽移动到所选择的相邻主要怪兽区域格子。
	Duel.MoveSequence(tc,nseq)
end
