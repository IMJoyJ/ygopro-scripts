--シャイニング・アンブラル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己把「阴影」怪兽或「假面魔蹈士」超量怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤，自己抽1张。那张抽到的卡是「阴影」怪兽的场合，可以再把那只怪兽特殊召唤。
-- ②：以怪兽3只以上为素材的「No.」超量怪兽超量召唤的场合，这张卡可以作为2只数量的超量素材。
local s,id,o=GetID()
-- 初始化卡片效果：注册效果①（手卡存在的场合型诱发效果，自己召唤·特殊召唤「阴影」怪兽或「假面魔蹈士」超量怪兽时可发动的自身特殊召唤与抽卡，1回合1次）和效果②（在怪兽区适用的永续效果，可作2只数量的超量素材，1回合1次）
function s.initial_effect(c)
	-- ①：自己把「阴影」怪兽或「假面魔蹈士」超量怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤，自己抽1张。那张抽到的卡是「阴影」怪兽的场合，可以再把那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以怪兽3只以上为素材的「No.」超量怪兽超量召唤的场合，这张卡可以作为2只数量的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.sxyzfilter)
	e3:SetValue(id)
	e3:SetCountLimit(1,id+o)
	c:RegisterEffect(e3)
end
-- 过滤器：筛选出表侧表示的、由自己召唤·特殊召唤的「阴影」怪兽或「假面魔蹈士」超量怪兽（0x87为阴影系列，0x1e3为假面魔蹈士系列）
function s.cfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x87) or c:IsSetCard(0x1e3) and c:IsType(TYPE_XYZ)) and c:IsSummonPlayer(tp)
end
-- 效果①的发动条件：本次召唤·特殊召唤成功的怪兽中存在满足条件的「阴影」怪兽或「假面魔蹈士」超量怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 效果①的发动检测：自己可以抽1张卡，且主要怪兽区有空位，并且这张卡可以从手卡特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检测自己主要怪兽区是否有空位，以及这张卡是否可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：宣言将特殊召唤这张卡（自身1张）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：宣言自己将抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的处理：这张卡从手卡特殊召唤，自己抽1张；抽到的卡是「阴影」怪兽的场合，可以让玩家选择再把那只怪兽特殊召唤（错时点处理）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与连锁关联，则将这张卡从手卡以表侧表示特殊召唤；特殊召唤成功才继续处理
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 自己抽1张卡；若没能抽到卡则中断后续处理
		if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
		-- 取得刚才抽卡操作实际抽到的卡
		local dc=Duel.GetOperatedGroup():GetFirst()
		if dc:IsSetCard(0x87) and dc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检测主要怪兽区有空位，并询问玩家是否将抽到的怪兽特殊召唤
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
			-- 中断当前效果，使之后的特殊召唤与抽卡视为不同时处理（错时点）
			Duel.BreakEffect()
			-- 将抽到的那只「阴影」怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(dc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果的对象过滤器：只对「No.」超量怪兽（0x48为No.系列）适用可作2只数量超量素材的效果
function s.sxyzfilter(e,c)
	return c:IsSetCard(0x48)
end
