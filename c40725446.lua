--熒焅聖 アレクゥス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：自己的魔法与陷阱区域有表侧表示卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：以自己场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。那之后，自己抽1张。
-- ③：这张卡被破坏的场合，以自己场上1只超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
local s,id,o=GetID()
-- 注册三个效果：①在手上作为规则特殊召唤的效果（EFFECT_SPSUMMON_PROC），②起动效果（破坏自身和一张表侧魔陷并抽卡），③被破坏时诱发效果（作为超量素材）。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己的魔法与陷阱区域有表侧表示卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：以自己场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合，以自己场上1只超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"作为超量素材"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡为表侧表示，且位于魔法与陷阱区域的通常区域（非场地魔法区域）。
function s.spcfilter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- ①规则特殊召唤的条件：若传入的c为空则视为无条件；否则检查自己主要怪兽区是否有空位，且自己魔法与陷阱区域存在至少1张表侧表示卡（非场地魔法区）。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在可用的主要怪兽区空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己魔法与陷阱区域是否存在至少1张满足spcfilter的表侧表示卡（即表侧且位于魔陷区前5格）。
		and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_SZONE,0,1,nil)
end
-- 过滤函数：判断卡为表侧表示，且属于魔法卡或陷阱卡。
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ②效果的发动条件与取对象判定：若在连锁确认对象阶段则验证对象合法性；若在发动时点则确认自身可被破坏、自己场上有除自身以外的表侧魔陷可选为对象、且自己可以抽1张卡。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c and s.desfilter(chkc) end
	if chk==0 then return c:IsDestructable()
		-- 检查自己场上是否存在除自身以外的表侧魔法·陷阱卡可以作为效果对象。
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,c)
		-- 检查自己是否可以抽1张卡。
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张除自身以外的表侧魔法·陷阱卡作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	g:AddCard(c)
	-- 设置操作信息：将对象组（选中的魔陷加上本卡）登记为将被破坏的卡，数量为2张。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：登记后续将进行抽1张卡的效果。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：若本卡和对象卡仍与当前连锁相关，则将两者以效果破坏；若两张都破坏成功，则中断当前效果处理，之后自己抽1张卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取该效果发动时选择的对象卡（唯一的表侧魔陷对象）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() then
		local g=Group.FromCards(c,tc)
		-- 以效果破坏由本卡和对象卡组成的组，若实际破坏了2张卡才继续抽卡处理。
		if Duel.Destroy(g,REASON_EFFECT)==2 then
			-- 中断当前效果处理，使后续抽卡与破坏效果不在同一时点处理，避免同步诱发时点。
			Duel.BreakEffect()
			-- 自己抽1张卡（原因为效果）。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 过滤函数：判断卡为表侧表示的超量怪兽。
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- ③效果的发动条件与取对象判定：若在连锁确认对象阶段则验证对象合法性；若在发动时点则确认自己场上有表侧超量怪兽可选择为对象，且本卡可以作为超量素材。
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xyzfilter(chkc) end
	-- 检查自己场上是否存在至少1只表侧表示的超量怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 向操作玩家显示“请选择效果的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的超量怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 若本卡位于墓地，则登记操作信息：本卡将离开墓地，用于响应“从墓地离开”的连锁检测。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- ③效果处理：若对象超量怪兽仍与连锁相关且不免疫此效果，同时本卡仍与连锁相关、可以作为超量素材且不受王家长眠之谷影响，则将本卡叠放在对象超量怪兽下方作为超量素材。
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取③效果选择的超量怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e)
		-- 同时确认本卡仍与当前连锁相关、可以作为超量素材，且本卡离开墓地不受王家长眠之谷等效果的限制。
		and c:IsRelateToChain() and c:IsCanOverlay() and aux.NecroValleyFilter()(c) then
		-- 将本卡作为超量素材叠放在目标超量怪兽下方。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
