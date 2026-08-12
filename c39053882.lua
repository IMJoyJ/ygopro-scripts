--Vアンブラル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「V阴影」以外的1只「阴影」怪兽加入手卡。
-- ②：把墓地的这张卡除外，以自己场上1只「假面魔蹈士」超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只「No.」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：e1/e2为这张卡召唤·特殊召唤成功时发动的检索加手效果（1回合1次），e3为墓地发动的、把墓地的这张卡除外并以自己场上「假面魔蹈士」超量怪兽为对象的超量召唤效果（1回合1次）
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「V阴影」以外的1只「阴影」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己场上1只「假面魔蹈士」超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只「No.」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"超量召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	-- 设定发动代价：把墓地的这张卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
-- 检索对象的过滤条件：不是「V阴影」本身的「阴影」字段且可以加入手卡的怪兽
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x87) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的目标函数：发动条件检测为卡组中存在可加入手卡的满足条件的怪兽，并声明将要从卡组把1张卡加入手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认自己卡组中存在至少1只满足条件的「阴影」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 声明操作信息：将从卡组把1张卡加入手卡（具体哪张在处理时才确定）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：提示后让玩家从卡组选1只满足条件的怪兽加入手卡，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1只满足条件的「阴影」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 把选择的怪兽以效果原因送入持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认被加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 对象过滤条件：自己场上表侧表示的「假面魔蹈士」超量怪兽，且额外卡组存在比其阶级高1阶的可特殊召唤的「No.」怪兽，并且该怪兽能成为超量素材
function s.filter1(c,e,tp)
	local rk=c:GetRank()
	return rk>0 and c:IsFaceup() and c:IsSetCard(0x1e3)
		-- 检查额外卡组是否存在比对象怪兽阶级高1阶、满足条件的「No.」怪兽
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1)
		-- 检查该怪兽是否受到必须成为超量素材的影响（能否作为超量素材使用）
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 额外卡组怪兽的过滤条件：指定阶级的「No.」怪兽，对象怪兽可作为其超量素材且能被当作超量召唤特殊召唤；另含特判：原卡号为6165656的怪兽仅在对象怪兽为卡号48995978时允许
function s.filter2(c,e,tp,mc,rk)
	if c:GetOriginalCode()==6165656 and not mc:IsCode(48995978) then return false end
	return c:IsRank(rk) and c:IsSetCard(0x48) and mc:IsCanBeXyzMaterial(c)
		-- 检查该「No.」怪兽能否被特殊召唤，以及场上是否有能让额外卡组怪兽出场的可用空格
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 超量召唤效果的目标函数：选择自己场上1只满足条件的超量怪兽为对象，并声明将从额外卡组特殊召唤1只怪兽
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	-- 发动条件检测：自己场上是否存在能成为效果对象的满足条件的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只满足条件的「假面魔蹈士」超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 声明操作信息：将从额外卡组把1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：取得对象怪兽并校验其状态，从额外卡组选出比其阶级高1阶的「No.」怪兽，把对象怪兽及其超量素材全部叠放到新怪兽下面后当作超量召唤特殊召唤，并完成正规出场手续
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍能作为超量素材使用，否则中断处理
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:GetControler()~=tp or tc:IsFacedown() or not tc:IsRelateToChain() or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只比对象怪兽阶级高1阶的满足条件的「No.」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 把对象怪兽原有的超量素材叠放到新怪兽下面
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 把对象怪兽本身叠放在新怪兽下面作为超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 把新怪兽当作超量召唤以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
